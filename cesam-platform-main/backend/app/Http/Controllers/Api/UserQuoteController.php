<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Quote;
use Illuminate\Http\JsonResponse;

class UserQuoteController extends Controller
{
    /**
     * Retourne la dernière citation publiée par l'admin.
     */
    public function latest(): JsonResponse
    {
        $quote = Quote::where('is_published', true)
                      ->orderBy('created_at', 'desc')
                      ->first(['id', 'text', 'author', 'submitted_by', 'created_at']);

        if (!$quote) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune citation disponible pour le moment.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $quote,
        ]);
    }
}
