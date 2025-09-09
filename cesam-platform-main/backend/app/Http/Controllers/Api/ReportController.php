<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    /**
     * Soumettre un PFE/PFA
     */
    public function store(Request $request)
    {
        try {
            // Validation avec les domaines exacts de votre enum
            $validated = $request->validate([
                'type' => 'required|in:PFE,PFA',
                'title' => 'required|string|max:500',
                'author_name' => 'required|string|max:255',
                'defense_year' => 'required|integer|min:2000|max:2100',
                'domain' => [
                    'required',
                    'string',
                    'in:Informatique & Numérique,Génie & Technologies,Sciences & Mathématiques,Économie & Gestion,Droit & Sciences politiques,Médecine & Santé,Arts & Lettres,Enseignement & Pédagogie,Agronomie & Environnement,Tourisme & Hôtellerie,Autres'
                ],
                'pdf_path' => 'required|file|mimes:pdf|max:10000',
            ]);

            // Stocker le fichier
            $path = $request->file('pdf_path')->store('reports', 'public');

            // Créer le rapport
            $report = Report::create([
                'user_id' => $request->user()->id,
                'author_name' => $validated['author_name'],
                'title' => $validated['title'],
                'type' => $validated['type'],
                'defense_year' => $validated['defense_year'],
                'domain' => $validated['domain'],
                'pdf_path' => $path,
                'status' => 'pending',
                'submitted_at' => now(),
            ]);

            Log::info('Rapport créé avec succès', ['report_id' => $report->id]);

            return response()->json([
                'message' => 'Rapport soumis avec succès',
                'report' => $report
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::warning('Erreur de validation', ['errors' => $e->errors()]);
            return response()->json([
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur soumission rapport', [
                'message' => $e->getMessage(),
                'user_id' => $request->user()?->id
            ]);

            return response()->json([
                'message' => 'Erreur interne du serveur',
                'error' => config('app.debug') ? $e->getMessage() : 'Une erreur est survenue'
            ], 500);
        }
    }

    /**
     * Voir les rapports acceptés (avec filtres éventuels)
     */
    public function index(Request $request)
    {
        try {
            $query = Report::where('status', 'accepted');

            if ($request->has('domain')) {
                $query->where('domain', $request->domain);
            }

            if ($request->has('defense_year')) {
                $query->where('defense_year', $request->defense_year);
            }

            // ✅ CORRECTION: Utilise nom_complet avec alias
            $reports = $query->with(['user' => function($query) {
                $query->select('id', 'nom_complet as name');
            }])->latest()->get();

            return response()->json($reports);

        } catch (\Exception $e) {
            Log::error('Erreur récupération rapports', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);

            return response()->json([
                'message' => 'Erreur lors de la récupération des rapports'
            ], 500);
        }
    }

    /**
     * ✅ NOUVELLE MÉTHODE : Télécharger/Visualiser un PDF
     */
    public function downloadPdf($id)
    {
        try {
            $report = Report::where('status', 'accepted')->findOrFail($id);
            
            // Vérifier si le fichier existe
            if (!Storage::disk('public')->exists($report->pdf_path)) {
                return response()->json([
                    'message' => 'Fichier PDF introuvable'
                ], 404);
            }

            $filePath = storage_path('app/public/' . $report->pdf_path);
            $fileName = $report->author_name . ' - ' . $report->title . '.pdf';

            return response()->download($filePath, $fileName, [
                'Content-Type' => 'application/pdf',
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur téléchargement PDF', [
                'report_id' => $id,
                'message' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Erreur lors du téléchargement du PDF'
            ], 500);
        }
    }

    /**
     * ✅ NOUVELLE MÉTHODE : Visualiser un PDF dans le navigateur
     */
    public function viewPdf($id)
    {
        try {
            $report = Report::where('status', 'accepted')->findOrFail($id);
            
            // Vérifier si le fichier existe
            if (!Storage::disk('public')->exists($report->pdf_path)) {
                return response()->json([
                    'message' => 'Fichier PDF introuvable'
                ], 404);
            }

            $filePath = storage_path('app/public/' . $report->pdf_path);
            
            return response()->file($filePath, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'inline; filename="' . $report->title . '.pdf"'
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur visualisation PDF', [
                'report_id' => $id,
                'message' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Erreur lors de la visualisation du PDF'
            ], 500);
        }
    }

    /**
     * ✅ NOUVELLE MÉTHODE : Stream un PDF (pour les gros fichiers)
     */
    public function streamPdf($id)
    {
        try {
            $report = Report::where('status', 'accepted')->findOrFail($id);
            
            if (!Storage::disk('public')->exists($report->pdf_path)) {
                return response()->json([
                    'message' => 'Fichier PDF introuvable'
                ], 404);
            }

            $filePath = storage_path('app/public/' . $report->pdf_path);
            
            return new StreamedResponse(function() use ($filePath) {
                $stream = fopen($filePath, 'rb');
                fpassthru($stream);
                fclose($stream);
            }, 200, [
                'Content-Type' => 'application/pdf',
                'Content-Length' => filesize($filePath),
                'Content-Disposition' => 'inline; filename="' . $report->title . '.pdf"',
                'Accept-Ranges' => 'bytes',
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur stream PDF', [
                'report_id' => $id,
                'message' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Erreur lors du streaming du PDF'
            ], 500);
        }
    }

    /**
     * ✅ NOUVELLE MÉTHODE : Obtenir les détails d'un rapport
     */
    public function show($id)
    {
        try {
            $report = Report::where('status', 'accepted')
                ->with(['user' => function($query) {
                    $query->select('id', 'nom_complet as name');
                }])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $report
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur récupération rapport', [
                'report_id' => $id,
                'message' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Rapport introuvable'
            ], 404);
        }
    }
}