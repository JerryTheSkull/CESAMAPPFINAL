<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Lieu;
use App\Models\PhotoLieu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class LieuManagementController extends Controller
{
    /**
     * Lister tous les lieux (admin) - incluant inactifs
     * GET /admin/lieux
     */
    public function index(Request $request)
    {
        try {
            $query = Lieu::with(['ville', 'categorie', 'auteur:id,nom_complet', 'photoprincipale']);

            // Filtres optionnels
            if ($request->has('ville_id') && $request->ville_id) {
                $query->where('ville_id', $request->ville_id);
            }

            if ($request->has('categorie_id') && $request->categorie_id) {
                $query->where('categorie_id', $request->categorie_id);
            }

            if ($request->has('is_active')) {
                $query->where('is_active', $request->boolean('is_active'));
            }

            if ($request->has('search') && $request->search) {
                $query->search($request->search);
            }

            $lieux = $query->orderBy('created_at', 'desc')->get();

            return response()->json([
                'success' => true,
                'message' => 'Liste des lieux (admin) récupérée avec succès',
                'data' => $lieux
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des lieux',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Ajouter un nouveau lieu (Admin seulement)
     * POST /admin/lieux
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'nom' => 'required|string|max:255',
                'description' => 'required|string',
                'adresse' => 'nullable|string',
                'ville_id' => 'required|exists:villes,id',
                'categorie_id' => 'required|exists:categories_lieux,id',
                'carte_url' => 'nullable|string|url',
                'horaires' => 'nullable|string',
                'latitude' => 'nullable|numeric|between:-90,90',
                'longitude' => 'nullable|numeric|between:-180,180',
                'telephone' => 'nullable|string|max:20',
                'email' => 'nullable|email',
                'site_web' => 'nullable|string|url',
                'prix_moyen' => 'nullable|numeric|min:0',
                'photos' => 'nullable|array',
                'photos.*' => 'image|mimes:jpeg,png,jpg|max:2048',
                'date_publication' => 'nullable|date',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Données de validation échouées',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            $lieuData = $request->only([
                'nom', 'description', 'adresse', 'ville_id', 'categorie_id',
                'carte_url', 'horaires', 'latitude', 'longitude', 
                'telephone', 'email', 'site_web', 'prix_moyen'
            ]);

            $lieuData['date_publication'] = $request->date_publication 
                ? $request->date_publication 
                : now();
            $lieuData['auteur_id'] = auth()->id();

            $lieu = Lieu::create($lieuData);

            // Gestion des photos
            if ($request->hasFile('photos')) {
                foreach ($request->file('photos') as $index => $photo) {
                    $photoPath = $photo->store('lieux/photos', 'public');
                    
                    PhotoLieu::create([
                        'lieu_id' => $lieu->id,
                        'url' => $photoPath,
                        'legende' => $request->input("photos_legendes.{$index}"),
                        'is_principale' => $index === 0, // Première photo = principale
                        'ordre' => $index + 1,
                    ]);
                }
            }

            DB::commit();

            $lieu->load(['ville', 'categorie', 'photos', 'auteur:id,nom_complet']);

            return response()->json([
                'success' => true,
                'message' => 'Lieu ajouté avec succès',
                'data' => $lieu
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'ajout du lieu',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Modifier un lieu existant (Admin seulement)
     * PUT /admin/lieux/:id
     */
    public function update(Request $request, $id)
    {
        try {
            $lieu = Lieu::find($id);

            if (!$lieu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Lieu non trouvé'
                ], 404);
            }

            $validator = Validator::make($request->all(), [
                'nom' => 'sometimes|string|max:255',
                'description' => 'sometimes|string',
                'adresse' => 'nullable|string',
                'ville_id' => 'sometimes|exists:villes,id',
                'categorie_id' => 'sometimes|exists:categories_lieux,id',
                'carte_url' => 'nullable|string|url',
                'horaires' => 'nullable|string',
                'latitude' => 'nullable|numeric|between:-90,90',
                'longitude' => 'nullable|numeric|between:-180,180',
                'telephone' => 'nullable|string|max:20',
                'email' => 'nullable|email',
                'site_web' => 'nullable|string|url',
                'prix_moyen' => 'nullable|numeric|min:0',
                'is_active' => 'boolean',
                'nouvelles_photos' => 'nullable|array',
                'nouvelles_photos.*' => 'image|mimes:jpeg,png,jpg|max:2048',
                'supprimer_photos' => 'nullable|array', // IDs des photos à supprimer
                'supprimer_photos.*' => 'integer|exists:photos_lieux,id',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Données de validation échouées',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            // Mise à jour des champs du lieu
            $updateData = $request->only([
                'nom', 'description', 'adresse', 'ville_id', 'categorie_id',
                'carte_url', 'horaires', 'latitude', 'longitude', 
                'telephone', 'email', 'site_web', 'prix_moyen', 'is_active'
            ]);

            $lieu->update($updateData);

            // Supprimer les photos sélectionnées
            if ($request->has('supprimer_photos') && is_array($request->supprimer_photos)) {
                $photosASupprimer = PhotoLieu::whereIn('id', $request->supprimer_photos)
                    ->where('lieu_id', $lieu->id)
                    ->get();

                foreach ($photosASupprimer as $photo) {
                    Storage::disk('public')->delete($photo->url);
                    $photo->delete();
                }
            }

            // Ajouter de nouvelles photos
            if ($request->hasFile('nouvelles_photos')) {
                $dernierOrdre = PhotoLieu::where('lieu_id', $lieu->id)->max('ordre') ?? 0;
                
                foreach ($request->file('nouvelles_photos') as $index => $photo) {
                    $photoPath = $photo->store('lieux/photos', 'public');
                    
                    PhotoLieu::create([
                        'lieu_id' => $lieu->id,
                        'url' => $photoPath,
                        'legende' => $request->input("nouvelles_photos_legendes.{$index}"),
                        'is_principale' => false, // Les nouvelles photos ne sont pas principales par défaut
                        'ordre' => $dernierOrdre + $index + 1,
                    ]);
                }
            }

            DB::commit();

            $lieu->load(['ville', 'categorie', 'photos', 'auteur:id,nom_complet']);

            return response()->json([
                'success' => true,
                'message' => 'Lieu mis à jour avec succès',
                'data' => $lieu
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour du lieu',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer un lieu (Admin seulement)
     * DELETE /admin/lieux/:id
     */
    public function destroy($id)
    {
        try {
            $lieu = Lieu::find($id);

            if (!$lieu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Lieu non trouvé'
                ], 404);
            }

            DB::beginTransaction();

            // Supprimer toutes les photos associées
            $photos = PhotoLieu::where('lieu_id', $lieu->id)->get();
            foreach ($photos as $photo) {
                Storage::disk('public')->delete($photo->url);
                $photo->delete();
            }

            // Supprimer le lieu
            $lieu->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Lieu supprimé avec succès'
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression du lieu',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}