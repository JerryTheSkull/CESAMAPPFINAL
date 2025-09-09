<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Video;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class VideoController extends Controller
{
    /**
     * Afficher les vidéos publiques avec statut des likes
     * GET /api/videos
     */
    public function index(Request $request)
    {
        try {
            $query = Video::with('auteur:id,nom_complet')
                         ->active() // Seulement les vidéos actives
                         ->where('date_publication', '<=', now()); // Seulement les vidéos déjà publiées

            // Filtrage par thème (pour ton Flutter)
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

            // Recherche
            if ($request->has('search') && $request->search) {
                $query->where(function($q) use ($request) {
                    $q->where('titre', 'like', '%' . $request->search . '%')
                      ->orWhere('description', 'like', '%' . $request->search . '%');
                });
            }

            // Tri par défaut : plus récentes en premier
            $sortBy = $request->get('sort_by', 'date_publication');
            $sortOrder = $request->get('sort_order', 'desc');
            $query->orderBy($sortBy, $sortOrder);

            // Récupérer toutes les vidéos (pas de pagination pour Flutter)
            $videos = $query->get();

            // Ajouter le statut "liked" pour l'utilisateur connecté
            if (Auth::check()) {
                $userId = Auth::id();
                foreach ($videos as $video) {
                    $video->liked = $video->isLikedByUser($userId);
                }
            } else {
                foreach ($videos as $video) {
                    $video->liked = false;
                }
            }

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
     * Afficher une vidéo spécifique et incrémenter les vues
     * GET /api/videos/{id}
     */
    public function show($id)
    {
        try {
            $video = Video::with('auteur:id,nom_complet')->active()->find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            // Incrémenter les vues
            $video->incrementViews();

            // Ajouter le statut "liked" pour l'utilisateur connecté
            if (Auth::check()) {
                $video->liked = $video->isLikedByUser(Auth::id());
            } else {
                $video->liked = false;
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
}