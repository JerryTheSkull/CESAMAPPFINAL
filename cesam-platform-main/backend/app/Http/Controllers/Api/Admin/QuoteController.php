<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Quote;
use App\Models\User;
use App\Notifications\QuotePublishedNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Log;


class QuoteController extends Controller
{
    public function index()
    {
        return response()->json([
            'published' => Quote::where('is_published', true)->with('user')->get(),
            'unpublished' => Quote::where('is_published', false)->with('user')->get(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'text' => 'required|string',
            'author' => 'required|string',
        ]);

        $quote = Quote::create([
            'text' => $validated['text'],
            'author' => $validated['author'],
            'submitted_by' => Auth::id(),
        ]);

        return response()->json($quote, 201);
    }

    public function update(Request $request, Quote $quote)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        if ($quote->submitted_by !== Auth::id() && !$user->hasRole('admin')) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'text' => 'sometimes|string',
            'author' => 'sometimes|string',
        ]);

        $quote->update($validated);

        return response()->json($quote);
    }

    public function destroy(Quote $quote)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        if ($quote->submitted_by !== Auth::id() && !$user->hasRole('admin')) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $quote->delete();
        return response()->json(['message' => 'Quote deleted successfully']);
    }

    public function publish(Quote $quote)
    {
        // Vérifier si la citation n'était pas déjà publiée
        $wasUnpublished = !$quote->is_published;
        
        $quote->update(['is_published' => true]);
        
        // Envoyer la notification seulement si la citation vient d'être publiée
        if ($wasUnpublished) {
            $this->sendQuoteNotification($quote);
        }

        return response()->json(['message' => 'Quote published', 'quote' => $quote]);
    }

    public function unpublish(Quote $quote)
    {
        $quote->update(['is_published' => false]);
        return response()->json(['message' => 'Quote unpublished', 'quote' => $quote]);
    }

    /**
     * Envoie une notification de nouvelle citation à tous les utilisateurs
     */
    private function sendQuoteNotification(Quote $quote)
    {
        try {
            // Option 1: Envoyer à tous les utilisateurs
            $users = User::all();
            Notification::send($users, new QuotePublishedNotification($quote));
            
            // Option 2: Ou envoyer seulement aux utilisateurs avec un rôle spécifique
            // $users = User::role('subscriber')->get(); // Si vous utilisez Spatie Permission
            // Notification::send($users, new QuotePublishedNotification($quote));
            
        } catch (\Exception $e) {
            // Log l'erreur mais ne pas faire échouer la publication
            Log::error('Erreur lors de l\'envoi de la notification de citation: ' . $e->getMessage());

        }
    }
}