<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Imports\ScholarshipsImport;
use App\Exports\ScholarshipsExport;
use App\Models\Scholarship;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use Illuminate\Http\JsonResponse;

class AdminScholarshipController extends Controller
{
    /**
     * Afficher toutes les bourses
     */
    public function index(): JsonResponse
    {
        $scholarships = Scholarship::all();
        
        return response()->json([
            'success' => true,
            'data' => $scholarships,
            'message' => 'Bourses récupérées avec succès'
        ]);
    }

    /**
     * Afficher une bourse spécifique
     */
    public function show($id): JsonResponse
    {
        $scholarship = Scholarship::find($id);
        
        if (!$scholarship) {
            return response()->json([
                'success' => false,
                'message' => 'Bourse non trouvée'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $scholarship,
            'message' => 'Bourse récupérée avec succès'
        ]);
    }

    /**
     * Créer une nouvelle bourse
     */
    public function store(Request $request): JsonResponse
    {
        $validatedData = $request->validate([
            'pays' => 'required|string|max:255',
            'amci_matricule' => 'required|string|max:255',
            'nom' => 'required|string|max:255',
            'passport' => 'required|string|max:255',
            'code' => 'required|string|max:255',
        ]);

        $scholarship = Scholarship::create($validatedData);

        return response()->json([
            'success' => true,
            'data' => $scholarship,
            'message' => 'Bourse créée avec succès'
        ], 201);
    }

    /**
     * Mettre à jour une bourse
     */
    public function update(Request $request, $id): JsonResponse
    {
        $scholarship = Scholarship::find($id);
        
        if (!$scholarship) {
            return response()->json([
                'success' => false,
                'message' => 'Bourse non trouvée'
            ], 404);
        }

        $validatedData = $request->validate([
            'pays' => 'sometimes|required|string|max:255',
            'amci_matricule' => 'sometimes|required|string|max:255',
            'nom' => 'sometimes|required|string|max:255',
            'passport' => 'sometimes|required|string|max:255',
            'code' => 'sometimes|required|string|max:255',
        ]);

        $scholarship->update($validatedData);

        return response()->json([
            'success' => true,
            'data' => $scholarship,
            'message' => 'Bourse mise à jour avec succès'
        ]);
    }

    /**
     * Supprimer une bourse
     */
    public function destroy($id): JsonResponse
    {
        $scholarship = Scholarship::find($id);
        
        if (!$scholarship) {
            return response()->json([
                'success' => false,
                'message' => 'Bourse non trouvée'
            ], 404);
        }

        $scholarship->delete();

        return response()->json([
            'success' => true,
            'message' => 'Bourse supprimée avec succès'
        ]);
    }

    public function getByMatricule($matricule): JsonResponse
{
    $scholarship = Scholarship::where('amci_matricule', $matricule)->first();

    if (!$scholarship) {
        return response()->json([
            'success' => false,
            'message' => 'Aucune bourse trouvée pour ce matricule',
        ], 404);
    }

    return response()->json([
        'success' => true,
        'data' => $scholarship,
    ]);
}


    /**
     * Importer des bourses depuis un fichier Excel
     * (ignore les noms de colonnes, lit uniquement par ordre)
     */
    public function import(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|mimes:xlsx,xls,csv|max:2048'
        ]);

        try {
            Excel::import(new ScholarshipsImport, $request->file('file'));

            return response()->json([
                'success' => true,
                'message' => 'Import réalisé avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'import: ' . $e->getMessage()
            ], 500);
        }
    }
}
