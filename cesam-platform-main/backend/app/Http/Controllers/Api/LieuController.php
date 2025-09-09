<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Lieu;
use App\Models\Ville;
use App\Models\CategorieLieu;
use Illuminate\Http\Request;

class LieuController extends Controller
{
    /**
     * Lister tous les lieux avec filtres optionnels (Public - Étudiant)
     * GET /lieux
     * GET /lieux?search=agadir
     * GET /lieux?ville=Rabat&type=musée
     */
    public function index(Request $request)
    {
        try {
            $query = Lieu::active()
                ->with(['ville', 'categorie', 'photoprincipale']);

            // Recherche textuelle
            if ($request->has('search') && $request->search) {
                $query->search($request->search);
            }

            // Filtrer par ville
            if ($request->has('ville') && $request->ville) {
                $query->byVille($request->ville);
            }

            // Filtrer par type/catégorie  
            if ($request->has('type') && $request->type) {
                $query->byCategorie($request->type);
            }

            // Filtrer par catégorie ID
            if ($request->has('categorie_id') && $request->categorie_id) {
                $query->where('categorie_id', $request->categorie_id);
            }

            // Filtrer par ville ID
            if ($request->has('ville_id') && $request->ville_id) {
                $query->where('ville_id', $request->ville_id);
            }

            // Pagination
            $perPage = $request->get('per_page', 15);
            $lieux = $query->orderBy('date_publication', 'desc')
                          ->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'Liste des lieux récupérée avec succès',
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
     * Voir les détails d'un lieu spécifique (Public - Étudiant)
     * GET /lieux/:id
     */
    public function show($id)
    {
        try {
            $lieu = Lieu::active()
                ->with(['ville', 'categorie', 'photos', 'auteur:id,nom_complet'])
                ->find($id);

            if (!$lieu) {
                return response()->json([
                    'success' => false,
                    'message' => 'Lieu non trouvé'
                ], 404);
            }

            // Incrémenter le nombre de vues
            $lieu->incrementViews();

            return response()->json([
                'success' => true,
                'message' => 'Détails du lieu récupérés avec succès',
                'data' => $lieu
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération du lieu',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtenir la liste des villes disponibles
     * GET /lieux/villes
     */
    public function getVilles()
    {
        try {
            $villes = Ville::orderBy('nom')->get();

            return response()->json([
                'success' => true,
                'message' => 'Liste des villes récupérée avec succès',
                'data' => $villes
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des villes',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtenir la liste des catégories de lieux
     * GET /lieux/categories
     */
    public function getCategories()
    {
        try {
            $categories = CategorieLieu::orderBy('nom')->get();

            return response()->json([
                'success' => true,
                'message' => 'Liste des catégories récupérée avec succès',
                'data' => $categories
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des catégories',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtenir les lieux populaires (plus consultés)
     * GET /lieux/populaires
     */
    public function getPopulaires(Request $request)
    {
        try {
            $limit = $request->get('limit', 10);
            
            $lieux = Lieu::active()
                ->with(['ville', 'categorie', 'photoprincipale'])
                ->orderBy('vues', 'desc')
                ->limit($limit)
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lieux populaires récupérés avec succès',
                'data' => $lieux
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des lieux populaires',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}