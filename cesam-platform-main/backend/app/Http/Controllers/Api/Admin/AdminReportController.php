<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminReportController extends Controller
{
    /**
     * Voir les rapports en attente
     */
    public function pending()
    {
        try {
            Log::info('Début récupération rapports admin');
            
            // Étape 1 : Vérifier que des rapports existent
            $totalReports = Report::count();
            $pendingCount = Report::where('status', 'pending')->count();
            
            Log::info('Stats rapports', [
                'total' => $totalReports,
                'pending' => $pendingCount
            ]);
            
            // Étape 2 : Récupérer sans relation d'abord
            $reportsWithoutUser = Report::where('status', 'pending')
                ->latest()
                ->get();
            
            Log::info('Rapports sans user récupérés', ['count' => $reportsWithoutUser->count()]);
            
            // Étape 3 : Ajouter la relation user avec la bonne colonne
            $reports = Report::where('status', 'pending')
                ->with(['user' => function($query) {
                    $query->select('id', 'nom_complet as name'); // Alias pour compatibilité
                }])
                ->latest()
                ->get();
                
            Log::info('Rapports avec user récupérés', ['count' => $reports->count()]);

            return response()->json([
                'success' => true,
                'data' => $reports,
                'meta' => [
                    'total' => $totalReports,
                    'pending' => $pendingCount
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur récupération rapports admin', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des rapports',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Voir tous les rapports avec filtres par statut
     */
    public function index(Request $request)
    {
        try {
            $status = $request->get('status', 'all');
            
            $query = Report::query();
            
            if ($status !== 'all') {
                $query->where('status', $status);
            }
            
            // Utiliser get() au lieu de paginate() pour Flutter
            $reports = $query->with(['user' => function($query) {
                $query->select('id', 'nom_complet as name');
            }, 'admin' => function($query) {
                $query->select('id', 'nom_complet as admin_name');
            }])
            ->latest()
            ->get();

            $stats = [
                'total' => Report::count(),
                'pending' => Report::where('status', 'pending')->count(),
                'accepted' => Report::where('status', 'accepted')->count(),
                'rejected' => Report::where('status', 'rejected')->count(),
            ];

            return response()->json([
                'success' => true,
                'data' => $reports,
                'stats' => $stats
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur récupération rapports admin', [
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des rapports',
                'data' => [],
                'stats' => []
            ], 500);
        }
    }

    /**
     * Mettre à jour le statut (accepter/rejeter/annuler)
     */
    public function updateStatus(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'status' => 'required|in:accepted,rejected,pending',
                'admin_comment' => 'nullable|string|max:1000'
            ]);

            $report = Report::findOrFail($id);
            $oldStatus = $report->status;

            $report->update([
                'status' => $validated['status'],
                'admin_id' => $request->user()->id,
                'admin_comment' => $validated['admin_comment'] ?? null,
                'processed_at' => now(),
            ]);

            Log::info('Statut rapport mis à jour', [
                'report_id' => $id,
                'old_status' => $oldStatus,
                'new_status' => $validated['status'],
                'admin_id' => $request->user()->id
            ]);

            return response()->json([
                'success' => true,
                'message' => "Statut mis à jour : {$validated['status']}",
                'data' => $report->load('user:id,nom_complet')
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur mise à jour statut', [
                'report_id' => $id,
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour du statut'
            ], 500);
        }
    }

    /**
     * Accepter un rapport
     */
    public function accept(Request $request, $id)
    {
        return $this->changeStatus($request, $id, 'accepted', 'Rapport accepté avec succès');
    }

    /**
     * Rejeter un rapport
     */
    public function reject(Request $request, $id)
    {
        $request->validate([
            'admin_comment' => 'required|string|max:1000'
        ], [
            'admin_comment.required' => 'Un commentaire est requis pour le rejet'
        ]);

        return $this->changeStatus($request, $id, 'rejected', 'Rapport rejeté');
    }

    /**
     * Annuler l'acceptation d'un rapport (remettre en pending)
     */
    public function cancelAcceptance(Request $request, $id)
    {
        try {
            DB::beginTransaction();

            $report = Report::findOrFail($id);

            // Vérifier que le rapport est bien accepté
            if ($report->status !== 'accepted') {
                return response()->json([
                    'success' => false,
                    'message' => 'Seuls les rapports acceptés peuvent être annulés'
                ], 400);
            }

            $report->update([
                'status' => 'pending',
                'admin_id' => $request->user()->id,
                'admin_comment' => $request->input('admin_comment', 'Acceptation annulée'),
                'processed_at' => now(),
            ]);

            Log::info('Acceptation rapport annulée', [
                'report_id' => $id,
                'admin_id' => $request->user()->id,
                'previous_status' => 'accepted'
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Acceptation annulée - Rapport remis en attente',
                'data' => $report->load('user:id,nom_complet')
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            
            Log::error('Erreur annulation acceptation', [
                'report_id' => $id,
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'annulation de l\'acceptation'
            ], 500);
        }
    }

    /**
     * Annuler le rejet d'un rapport (remettre en pending)
     */
    public function cancelRejection(Request $request, $id)
    {
        try {
            DB::beginTransaction();

            $report = Report::findOrFail($id);

            // Vérifier que le rapport est bien rejeté
            if ($report->status !== 'rejected') {
                return response()->json([
                    'success' => false,
                    'message' => 'Seuls les rapports rejetés peuvent être annulés'
                ], 400);
            }

            $report->update([
                'status' => 'pending',
                'admin_id' => $request->user()->id,
                'admin_comment' => $request->input('admin_comment', 'Rejet annulé'),
                'processed_at' => now(),
            ]);

            Log::info('Rejet rapport annulé', [
                'report_id' => $id,
                'admin_id' => $request->user()->id,
                'previous_status' => 'rejected'
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Rejet annulé - Rapport remis en attente',
                'data' => $report->load('user:id,nom_complet')
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            
            Log::error('Erreur annulation rejet', [
                'report_id' => $id,
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'annulation du rejet'
            ], 500);
        }
    }

    /**
     * Historique des modifications d'un rapport
     */
    public function history($id)
    {
        try {
            $report = Report::with(['user:id,nom_complet', 'admin:id,nom_complet'])
                ->findOrFail($id);

            // Si vous avez un système d'audit/logs, vous pouvez l'utiliser ici
            // Sinon, retourner les infos actuelles
            return response()->json([
                'success' => true,
                'data' => [
                    'report' => $report,
                    'current_status' => $report->status,
                    'processed_by' => $report->admin ? $report->admin->nom_complet : null,
                    'processed_at' => $report->processed_at,
                    'admin_comment' => $report->admin_comment,
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur historique rapport', [
                'report_id' => $id,
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération de l\'historique'
            ], 500);
        }
    }

    /**
     * Obtenir les détails d'un rapport (pour admin)
     */
    public function show($id)
    {
        try {
            // Admin peut voir tous les rapports, pas seulement acceptés
            $report = Report::with(['user' => function($query) {
                $query->select('id', 'nom_complet as name');
            }, 'admin' => function($query) {
                $query->select('id', 'nom_complet as admin_name');
            }])->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $report
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur récupération rapport admin', [
                'report_id' => $id,
                'message' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Rapport introuvable'
            ], 404);
        }
    }

    /**
     * Télécharger un PDF (pour admin)
     */
    public function downloadPdf($id)
    {
        try {
            // Admin peut télécharger tous les rapports, pas seulement acceptés
            $report = Report::findOrFail($id);
            
            // Vérifier si le fichier existe
            if (!Storage::disk('public')->exists($report->pdf_path)) {
                Log::warning('Fichier PDF introuvable', [
                    'report_id' => $id,
                    'pdf_path' => $report->pdf_path
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Fichier PDF introuvable'
                ], 404);
            }

            $filePath = storage_path('app/public/' . $report->pdf_path);
            $fileName = $report->author_name . ' - ' . $report->title . '.pdf';

            Log::info('Téléchargement PDF admin', [
                'report_id' => $id,
                'file_path' => $filePath,
                'file_exists' => file_exists($filePath)
            ]);

            return response()->download($filePath, $fileName, [
                'Content-Type' => 'application/pdf',
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur téléchargement PDF admin', [
                'report_id' => $id,
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du téléchargement du PDF'
            ], 500);
        }
    }

    /**
     * Visualiser un PDF (pour admin)
     */
    public function viewPdf($id)
    {
        try {
            // Admin peut visualiser tous les rapports
            $report = Report::findOrFail($id);
            
            // Vérifier si le fichier existe
            if (!Storage::disk('public')->exists($report->pdf_path)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Fichier PDF introuvable'
                ], 404);
            }

            $filePath = storage_path('app/public/' . $report->pdf_path);
            
            return response()->file($filePath, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'inline; filename="' . $report->title . '.pdf"'
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur visualisation PDF admin', [
                'report_id' => $id,
                'message' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la visualisation du PDF'
            ], 500);
        }
    }

    /**
     * Stream un PDF (pour admin)
     */
    public function streamPdf($id)
    {
        try {
            $report = Report::findOrFail($id);
            
            if (!Storage::disk('public')->exists($report->pdf_path)) {
                return response()->json([
                    'success' => false,
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
            Log::error('Erreur stream PDF admin', [
                'report_id' => $id,
                'message' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du streaming du PDF'
            ], 500);
        }
    }

    /**
     * Méthode privée : Changer le statut d'un rapport
     */
    private function changeStatus(Request $request, $id, $status, $message)
    {
        try {
            DB::beginTransaction();

            $validated = $request->validate([
                'admin_comment' => 'nullable|string|max:1000'
            ]);

            $report = Report::findOrFail($id);
            $oldStatus = $report->status;

            $report->update([
                'status' => $status,
                'admin_id' => $request->user()->id,
                'admin_comment' => $validated['admin_comment'] ?? null,
                'processed_at' => now(),
            ]);

            Log::info('Statut rapport changé', [
                'report_id' => $id,
                'old_status' => $oldStatus,
                'new_status' => $status,
                'admin_id' => $request->user()->id
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => $report->load('user:id,nom_complet')
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            
            Log::error('Erreur changement statut', [
                'report_id' => $id,
                'status' => $status,
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du changement de statut'
            ], 500);
        }
    }
}