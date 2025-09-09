<?php

namespace App\Http\Controllers\Api\Admin;
use App\Http\Controllers\Controller;
use App\Models\Video;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class AdminVideoController extends Controller
{
    /**
     * Middleware pour vérifier les permissions admin
     */
    public function __construct()
    {
        $this->middleware('auth:sanctum');
        $this->middleware('admin'); // Assumer qu'il y a un middleware admin
    }

    /**
     * Afficher toutes les vidéos (Admin) avec pagination
     * GET /admin/videos
     */
    public function index(Request $request)
    {
        try {
            $query = Video::with('auteur:id,nom_complet');

            // Filtrage par statut (actif/inactif)
            if ($request->has('status')) {
                if ($request->status === 'active') {
                    $query->where('is_active', true);
                } elseif ($request->status === 'inactive') {
                    $query->where('is_active', false);
                }
            }

            // Filtrage par thème
            if ($request->has('theme') && $request->theme) {
                $query->byTheme($request->theme);
            }

            // Filtrage par type (live/normal)
            if ($request->has('type')) {
                if ($request->type === 'live') {
                    $query->where('is_live', true);
                } elseif ($request->type === 'normal') {
                    $query->where('is_live', false);
                }
            }

            // Recherche par titre ou description
            if ($request->has('search') && $request->search) {
                $query->where(function($q) use ($request) {
                    $q->where('titre', 'like', '%' . $request->search . '%')
                      ->orWhere('description', 'like', '%' . $request->search . '%');
                });
            }

            // Tri
            $sortBy = $request->get('sort_by', 'date_publication');
            $sortOrder = $request->get('sort_order', 'desc');
            $query->orderBy($sortBy, $sortOrder);

            // Pagination
            $perPage = $request->get('per_page', 15);
            $videos = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'Liste des vidéos récupérée avec succès',
                'data' => $videos
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des vidéos',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Créer une nouvelle vidéo (Admin)
     * POST /admin/videos
     */
    public function store(Request $request)
    {
        try {
            // Validation des données
            $validator = Validator::make($request->all(), [
                'titre' => 'required|string|max:255',
                'description' => 'nullable|string|max:1000',
                'url' => 'required|url|max:500',
                'theme' => 'required|string|in:Chaîne TV étudiante,Documentaires & Films',
                'miniature' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
                'is_live' => 'boolean',
                'duree' => 'nullable|integer|min:1',
                'date_publication' => 'nullable|date|after_or_equal:today'
            ], [
                'titre.required' => 'Le titre est obligatoire',
                'url.required' => 'L\'URL de la vidéo est obligatoire',
                'url.url' => 'L\'URL doit être valide',
                'theme.required' => 'Le thème est obligatoire',
                'theme.in' => 'Le thème doit être "Chaîne TV étudiante" ou "Documentaires & Films"',
                'miniature.image' => 'La miniature doit être une image',
                'miniature.max' => 'La miniature ne doit pas dépasser 2MB',
                'duree.min' => 'La durée doit être supérieure à 0',
                'date_publication.after_or_equal' => 'La date de publication ne peut pas être dans le passé'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Gestion de l'upload de la miniature
            $miniatureUrl = null;
            if ($request->hasFile('miniature')) {
                $miniatureUrl = $request->file('miniature')->store('thumbnails', 'public');
            }

            // Créer la vidéo
            $video = Video::create([
                'titre' => $request->titre,
                'description' => $request->description,
                'url' => $request->url,
                'miniature' => $miniatureUrl,
                'theme' => $request->theme,
                'is_live' => $request->boolean('is_live', false),
                'is_active' => true, // Par défaut active
                'duree' => $request->duree,
                'vues' => 0,
                'date_publication' => $request->date_publication ?? now(),
                'auteur_id' => Auth::id()
            ]);

            $video->load('auteur:id,nom_complet');

            return response()->json([
                'success' => true,
                'message' => 'Vidéo créée avec succès',
                'data' => $video
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création de la vidéo',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Afficher une vidéo spécifique (Admin)
     * GET /admin/videos/:id
     */
    public function show($id)
    {
        try {
            $video = Video::with('auteur:id,nom_complet')->find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Vidéo récupérée avec succès',
                'data' => $video
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération de la vidéo',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour une vidéo (Admin)
     * PUT/PATCH /admin/videos/:id
     */
    public function update(Request $request, $id)
    {
        try {
            $video = Video::find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            // Validation
            $validator = Validator::make($request->all(), [
                'titre' => 'sometimes|required|string|max:255',
                'description' => 'nullable|string|max:1000',
                'url' => 'sometimes|required|url|max:500',
                'theme' => 'sometimes|required|string|in:Chaîne TV étudiante,Documentaires & Films',
                'miniature' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
                'is_live' => 'boolean',
                'is_active' => 'boolean',
                'duree' => 'nullable|integer|min:1',
                'date_publication' => 'nullable|date'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Gestion de la nouvelle miniature
            if ($request->hasFile('miniature')) {
                // Supprimer l'ancienne miniature si elle existe
                if ($video->miniature) {
                    Storage::disk('public')->delete($video->miniature);
                }
                $video->miniature = $request->file('miniature')->store('thumbnails', 'public');
            }

            // Mettre à jour les autres champs
            $video->fill($request->except(['miniature']));
            $video->save();

            $video->load('auteur:id,nom_complet');

            return response()->json([
                'success' => true,
                'message' => 'Vidéo mise à jour avec succès',
                'data' => $video
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour de la vidéo',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer une vidéo (Admin)
     * DELETE /admin/videos/:id
     */
    public function destroy($id)
    {
        try {
            $video = Video::find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            // Supprimer la miniature du stockage
            if ($video->miniature) {
                Storage::disk('public')->delete($video->miniature);
            }

            $titre = $video->titre;
            $video->delete();

            return response()->json([
                'success' => true,
                'message' => "Vidéo '$titre' supprimée avec succès"
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression de la vidéo',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Activer/Désactiver une vidéo (Admin)
     * PATCH /admin/videos/:id/toggle-status
     */
    public function toggleStatus($id)
    {
        try {
            $video = Video::find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            $video->is_active = !$video->is_active;
            $video->save();

            $status = $video->is_active ? 'activée' : 'désactivée';

            return response()->json([
                'success' => true,
                'message' => "Vidéo '$video->titre' $status avec succès",
                'data' => ['is_active' => $video->is_active]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du changement de statut',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtenir les statistiques des vidéos (Admin)
     * GET /admin/videos/stats
     */
    public function getStats()
    {
        try {
            $stats = [
                'total_videos' => Video::count(),
                'active_videos' => Video::active()->count(),
                'inactive_videos' => Video::where('is_active', false)->count(),
                'live_videos' => Video::live()->count(),
                'total_views' => Video::sum('vues'),
                'videos_by_theme' => Video::selectRaw('theme, COUNT(*) as count')
                    ->groupBy('theme')
                    ->pluck('count', 'theme'),
                'recent_videos' => Video::where('created_at', '>=', now()->subDays(7))->count(),
                'most_viewed' => Video::active()
                    ->orderBy('vues', 'desc')
                    ->limit(5)
                    ->get(['id', 'titre', 'vues']),
                'latest_videos' => Video::with('auteur:id,nom_complet')
                    ->orderBy('created_at', 'desc')
                    ->limit(5)
                    ->get(['id', 'titre', 'created_at', 'auteur_id', 'vues'])
            ];

            return response()->json([
                'success' => true,
                'message' => 'Statistiques récupérées avec succès',
                'data' => $stats
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Upload d'une miniature pour une vidéo
     * POST /admin/videos/:id/thumbnail
     */
    public function uploadThumbnail(Request $request, $id)
    {
        try {
            $video = Video::find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            $validator = Validator::make($request->all(), [
                'thumbnail' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
            ], [
                'thumbnail.required' => 'L\'image est obligatoire',
                'thumbnail.image' => 'Le fichier doit être une image',
                'thumbnail.mimes' => 'L\'image doit être au format JPEG, PNG, JPG ou GIF',
                'thumbnail.max' => 'L\'image ne doit pas dépasser 2MB'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Supprimer l'ancienne miniature
            if ($video->miniature) {
                Storage::disk('public')->delete($video->miniature);
            }

            // Sauvegarder la nouvelle miniature
            $thumbnailPath = $request->file('thumbnail')->store('thumbnails', 'public');
            $video->miniature = $thumbnailPath;
            $video->save();

            return response()->json([
                'success' => true,
                'message' => 'Miniature mise à jour avec succès',
                'data' => [
                    'thumbnail_url' => Storage::url($thumbnailPath)
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'upload de la miniature',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer plusieurs vidéos en lot (Admin)
     * DELETE /admin/videos/bulk
     */
    public function bulkDelete(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'video_ids' => 'required|array|min:1',
                'video_ids.*' => 'integer|exists:videos,id'
            ], [
                'video_ids.required' => 'Au moins une vidéo doit être sélectionnée',
                'video_ids.array' => 'Les IDs doivent être dans un tableau',
                'video_ids.*.exists' => 'Une ou plusieurs vidéos n\'existent pas'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            $videos = Video::whereIn('id', $request->video_ids)->get();
            
            // Supprimer les miniatures associées
            foreach ($videos as $video) {
                if ($video->miniature) {
                    Storage::disk('public')->delete($video->miniature);
                }
            }

            $deletedCount = Video::whereIn('id', $request->video_ids)->delete();

            return response()->json([
                'success' => true,
                'message' => "$deletedCount vidéo(s) supprimée(s) avec succès"
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression en lot',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Changer le statut de plusieurs vidéos (Admin)
     * PATCH /admin/videos/bulk-status
     */
    public function bulkUpdateStatus(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'video_ids' => 'required|array|min:1',
                'video_ids.*' => 'integer|exists:videos,id',
                'is_active' => 'required|boolean'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            $updatedCount = Video::whereIn('id', $request->video_ids)
                ->update(['is_active' => $request->is_active]);

            $status = $request->is_active ? 'activées' : 'désactivées';

            return response()->json([
                'success' => true,
                'message' => "$updatedCount vidéo(s) $status avec succès"
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour en lot',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtenir les thèmes disponibles avec compteur (Admin)
     * GET /admin/videos/themes
     */
    public function getThemesWithCount()
    {
        try {
            $themes = Video::selectRaw('theme, COUNT(*) as total, SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active')
                ->whereNotNull('theme')
                ->groupBy('theme')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Thèmes récupérés avec succès',
                'data' => $themes
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des thèmes',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Dupliquer une vidéo (Admin)
     * POST /admin/videos/:id/duplicate
     */
    public function duplicate($id)
    {
        try {
            $originalVideo = Video::find($id);

            if (!$originalVideo) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            // Créer une copie
            $duplicateVideo = $originalVideo->replicate();
            $duplicateVideo->titre = $originalVideo->titre . ' (Copie)';
            $duplicateVideo->is_active = false; // Désactivée par défaut
            $duplicateVideo->vues = 0; // Remettre à zéro
            $duplicateVideo->date_publication = now();
            $duplicateVideo->auteur_id = Auth::id();
            $duplicateVideo->save();

            $duplicateVideo->load('auteur:id,nom_complet');

            return response()->json([
                'success' => true,
                'message' => 'Vidéo dupliquée avec succès',
                'data' => $duplicateVideo
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la duplication',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Programmer la publication d'une vidéo (Admin)
     * POST /admin/videos/:id/schedule
     */
    public function schedule(Request $request, $id)
    {
        try {
            $video = Video::find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            $validator = Validator::make($request->all(), [
                'date_publication' => 'required|date|after:now'
            ], [
                'date_publication.required' => 'La date de publication est obligatoire',
                'date_publication.after' => 'La date de publication doit être dans le futur'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }

            $video->date_publication = $request->date_publication;
            $video->is_active = false; // Désactiver jusqu'à la date programmée
            $video->save();

            return response()->json([
                'success' => true,
                'message' => 'Publication programmée avec succès',
                'data' => [
                    'scheduled_date' => $video->date_publication,
                    'video_title' => $video->titre
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la programmation',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}