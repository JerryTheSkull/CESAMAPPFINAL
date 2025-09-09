<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Video;
use App\Models\Like;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class VideoLikeController extends Controller
{
    /**
     * Middleware pour vérifier l'authentification
     */
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    /**
     * Liker/Unliker une vidéo
     * POST /api/videos/{id}/toggle-like
     */
    public function toggleLike($id)
    {
        try {
            $video = Video::find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            $userId = Auth::id();
            $existingLike = Like::where('user_id', $userId)
                               ->where('video_id', $id)
                               ->first();

            if ($existingLike) {
                // Unliker la vidéo
                $existingLike->delete();
                $video->decrementLikes();
                $liked = false;
                $message = 'Like retiré avec succès';
            } else {
                // Liker la vidéo
                Like::create([
                    'user_id' => $userId,
                    'video_id' => $id
                ]);
                $video->incrementLikes();
                $liked = true;
                $message = 'Vidéo likée avec succès';
            }

            // Recharger la vidéo pour avoir le nouveau nombre de likes
            $video->refresh();

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => [
                    'liked' => $liked,
                    'likes_count' => $video->likes
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la gestion du like',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Vérifier si l'utilisateur a liké une vidéo
     * GET /api/videos/{id}/like-status
     */
    public function checkLikeStatus($id)
    {
        try {
            $video = Video::find($id);

            if (!$video) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vidéo non trouvée'
                ], 404);
            }

            $userId = Auth::id();
            $liked = Like::where('user_id', $userId)
                         ->where('video_id', $id)
                         ->exists();

            return response()->json([
                'success' => true,
                'data' => [
                    'liked' => $liked,
                    'likes_count' => $video->likes
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la vérification du statut',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}