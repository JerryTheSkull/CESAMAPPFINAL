<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Offer;
use App\Models\User;
use App\Models\Application;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OfferController extends Controller
{
    /**
     * Liste toutes les offres actives
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $offers = Offer::active()->get();
        return response()->json($offers);
    }

    /**
     * Affiche le détail d'une offre
     *
     * @param Offer $offer
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Offer $offer)
    {
        /** @var User|null $user */
        $user = Auth::user();

        $data = $offer->only(['id', 'title', 'type', 'description', 'images', 'links', 'pdfs']);

        if ($user) {
            $data['user_has_applied'] = $user->hasAppliedToOffer($offer);
        } else {
            $data['user_has_applied'] = false;
        }

        return response()->json($data);
    }

    /**
     * Postuler à une offre
     *
     * @param Offer $offer
     * @return \Illuminate\Http\JsonResponse
     */
    public function apply(Offer $offer)
    {
        /** @var User $user */
        $user = Auth::user();

        if (!$offer->is_active) {
            return response()->json(['message' => 'This offer is not active'], 400);
        }

        if (!$user->hasAppliedToOffer($offer)) {
            Application::create([
                'user_id' => $user->id,
                'offer_id' => $offer->id,
                'applied_at' => now()
            ]);
            return response()->json(['message' => 'Applied successfully']);
        }

        return response()->json(['message' => 'Already applied'], 400);
    }

    /**
     * Liste les candidatures de l'utilisateur connecté
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function myApplications()
    {
        /** @var User $user */
        $user = Auth::user();

        $applications = $user->applications()
            ->with('offer:id,title,type,description')
            ->get()
            ->map(function($application) {
                return [
                    'id' => $application->id,
                    'offer' => $application->offer,
                    'applied_at' => $application->applied_at // Utiliser applied_at comme dans votre migration
                ];
            });

        return response()->json($applications);
    }

    /**
     * Annuler une postulation
     *
     * @param Application $application
     * @return \Illuminate\Http\JsonResponse
     */
    public function cancelApplication(Application $application)
    {
        /** @var User $user */
        $user = Auth::user();

        // Vérifier que l'application appartient bien à l'utilisateur connecté
        if ($application->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $application->delete();

        return response()->json(['message' => 'Application cancelled successfully']);
    }
}