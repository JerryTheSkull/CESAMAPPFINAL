<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Offer;
use Illuminate\Http\Request;

class AdminOfferController extends Controller
{
    /**
     * Liste toutes les offres avec le nombre de candidatures
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $offers = Offer::withCount('applications')->get();
        return response()->json($offers);
    }

    /**
     * Créer une nouvelle offre
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'type' => 'required|string|in:stage,emploi',
            'description' => 'nullable|string',
            'images' => 'nullable|array',
            'images.*' => 'nullable|string', // URLs ou chemins des images
            'pdfs' => 'nullable|array',
            'pdfs.*' => 'nullable|string', // URLs ou chemins des PDFs
            'links' => 'nullable|array',
            'links.*' => 'nullable|url', // URLs externes
            'is_active' => 'boolean',
        ]);

        // Définir is_active à true par défaut si non fourni
        $data['is_active'] = $data['is_active'] ?? true;

        $offer = Offer::create($data);
        
        return response()->json([
            'message' => 'Offer created successfully',
            'offer' => $offer
        ], 201);
    }

    /**
     * Afficher une offre spécifique avec ses candidatures
     *
     * @param Offer $offer
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Offer $offer)
    {
        $offer->load('applications.user:id,nom_complet,competences,projects');
        return response()->json($offer);
    }

    /**
     * Supprimer une offre
     *
     * @param Offer $offer
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Offer $offer)
    {
        // Supprimer d'abord toutes les candidatures liées
        $offer->applications()->delete();
        
        // Puis supprimer l'offre
        $offer->delete();
        
        return response()->json(['message' => 'Offer deleted successfully']);
    }

    /**
     * Changer le statut d'une offre (actif/inactif)
     *
     * @param Offer $offer
     * @return \Illuminate\Http\JsonResponse
     */
    public function toggleStatus(Offer $offer)
    {
        $offer->update(['is_active' => !$offer->is_active]);
        
        $status = $offer->is_active ? 'activated' : 'deactivated';
        
        return response()->json([
            'message' => "Offer {$status} successfully",
            'is_active' => $offer->is_active
        ]);
    }

    /**
     * Télécharger les informations des candidats (pour Excel côté Flutter)
     *
     * @param Offer $offer
     * @return \Illuminate\Http\JsonResponse
     */
    public function downloadExcel(Offer $offer)
    {
        $applicants = $offer->applications()->with('user:id,nom_complet,competences,projects')->get()->map(function($application) {
            $user = $application->user;
            return [
                'nom_complet' => $user->nom_complet ?? '',
                'competences' => $user->competences ?? [],
                'projects' => $user->projects ?? [],
                'applied_at' => $application->applied_at->format('Y-m-d H:i:s') // Utiliser applied_at
            ];
        });

        return response()->json([
            'offer_title' => $offer->title,
            'total_applicants' => $applicants->count(),
            'applicants' => $applicants
        ]);
    }

    /**
     * Obtenir les candidatures d'une offre (alias de downloadExcel pour compatibilité)
     *
     * @param Offer $offer
     * @return \Illuminate\Http\JsonResponse
     */
    public function applications(Offer $offer)
    {
        return $this->downloadExcel($offer);
    }
}