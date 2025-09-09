<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Services\AdvancedRegistrationService;
use App\Exceptions\RegistrationException;
use App\Models\RegistrationAuditLog;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Ramsey\Uuid\Uuid;

class RegisterController extends Controller
{
    private AdvancedRegistrationService $registrationService;

    public function __construct(AdvancedRegistrationService $registrationService)
    {
        $this->registrationService = $registrationService;
        
        // Rate limiting pour éviter les abus
        $this->middleware('throttle:60,1')->except(['getStepData', 'getProcessStatus']);
    }

    /**
     * Étape 1 : Informations personnelles - TOUS OBLIGATOIRES
     */
    public function step1(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'nom_complet' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:users,email',
                'password' => 'required|string|min:6',
                'telephone' => 'required|string|max:20',
                'nationalite' => 'required|string|max:100',
                'session_token' => 'nullable|string|size:64',
            ]);

            $result = $this->registrationService->step1($validated['session_token'] ?? null, $validated);
            return response()->json($result, 201);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur step1', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Étape 2 : Éducation - TOUS OBLIGATOIRES
     */
    public function step2(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
                'ecole' => 'required|string|max:255',
                'filiere' => 'required|string|max:255',
                'niveau_etude' => 'required|string|max:255',
                'ville' => 'required|string|max:255',
            ]);

            $sessionToken = $validated['session_token'];
            unset($validated['session_token']);

            $result = $this->registrationService->step2($sessionToken, $validated);
            return response()->json($result);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur step2', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Étape 3 : Profil académique - TOUS OPTIONNELS
     * Projets maintenant stockés en JSON avec UUIDs
     */
    public function step3(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
                'cv_file' => 'nullable|file|mimes:pdf|max:5120', // 5MB max pour PDF
                'competences' => 'nullable|array',
                'competences.*' => 'string|max:100', // Validation des compétences individuelles
                'projects' => 'nullable|array',
                'projects.*.title' => 'required_with:projects|string|max:200', // Cohérent avec UserProfileController
                'projects.*.description' => 'required_with:projects|string|max:1000',
                'projects.*.link' => 'nullable|url|max:255', // Validation URL comme dans UserProfileController
            ]);

            $sessionToken = $validated['session_token'];
            unset($validated['session_token']);

            // Traitement du fichier CV s'il est présent
            if ($request->hasFile('cv_file')) {
                $cvFile = $request->file('cv_file');
                
                // Générer un nom unique pour le fichier
                $fileName = 'cv_' . time() . '_' . uniqid() . '.' . $cvFile->getClientOriginalExtension();
                
                // Stocker le fichier dans le dossier storage/app/public/cvs
                $cvPath = $cvFile->storeAs('cvs', $fileName, 'public');
                
                // Ajouter le chemin du CV aux données validées (pas l'URL complète)
                $validated['cv_url'] = $cvPath; // Stockage du chemin relatif
            }

            // Supprimer cv_file des données car ce n'est pas un champ de la base de données
            unset($validated['cv_file']);

            // Formater les projets avec UUIDs et timestamps comme dans UserProfileController
            if (isset($validated['projects']) && is_array($validated['projects'])) {
                $formattedProjects = [];
                foreach ($validated['projects'] as $project) {
                    $formattedProjects[] = [
                        'id' => Uuid::uuid4()->toString(), // UUID unique pour chaque projet
                        'title' => $project['title'],
                        'description' => $project['description'],
                        'link' => $project['link'] ?? null,
                        'created_at' => now()->toIso8601String(), // Timestamp de création
                    ];
                }
                $validated['projects'] = $formattedProjects;
            }

            // Nettoyer et formater les compétences
            if (isset($validated['competences']) && is_array($validated['competences'])) {
                $competences = array_map('strtolower', array_map('trim', $validated['competences']));
                $competences = array_filter($competences, fn($skill) => !empty($skill));
                $validated['competences'] = array_unique($competences);
            }

            $result = $this->registrationService->step3($sessionToken, $validated);
            return response()->json($result);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur step3', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Étape 4 : AMCI + Envoi du code de vérification
     */
    public function step4(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
                'code_amci' => 'nullable|string|max:20',
                'affilie_amci' => 'nullable|boolean',
            ]);

            $sessionToken = $validated['session_token'];
            unset($validated['session_token']);

            $result = $this->registrationService->step4($sessionToken, $validated);
            return response()->json($result);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur step4', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Étape 5 : Vérification du code + Finalisation
     */
    public function step5(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
                'verification_code' => 'required|string|size:6',
            ]);

            $result = $this->registrationService->step5($validated['session_token'], $validated);
            return response()->json($result);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur step5', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'token_length' => strlen($request->input('session_token', '')),
                'token_raw' => $request->input('session_token', '')
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Renvoyer le code de vérification
     */
    public function resendVerificationCode(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
            ]);

            $result = $this->registrationService->resendVerificationCode($validated['session_token']);
            return response()->json($result);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);

        } catch (\Exception $e) {
            Log::error('Erreur resend code', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Récupérer les données d'une étape (pour navigation arrière)
     */
    public function getStepData(Request $request, int $stepNumber): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
            ]);

            if ($stepNumber < 1 || $stepNumber > 5) {
                return response()->json([
                    'success' => false,
                    'message' => 'Numéro d\'étape invalide'
                ], 400);
            }

            $process = $this->registrationService->getValidProcess($validated['session_token']);
            $stepData = $this->registrationService->getStepData($process, $stepNumber);

            return response()->json([
                'success' => true,
                'data' => $stepData,
                'step_number' => $stepNumber,
                'current_step' => $process->current_step
            ]);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 404);

        } catch (\Exception $e) {
            Log::error('Erreur get step data', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Obtenir l'état du processus d'inscription
     */
    public function getProcessStatus(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
            ]);

            $process = $this->registrationService->getValidProcess($validated['session_token']);

            return response()->json([
                'success' => true,
                'data' => [
                    'current_step' => $process->current_step,
                    'total_steps' => $process->total_steps,
                    'status' => $process->status,
                    'user_email' => $process->user_email,
                    'expires_at' => $process->expires_at->toIso8601String(),
                    'created_at' => $process->created_at->toIso8601String()
                ]
            ]);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 404);

        } catch (\Exception $e) {
            Log::error('Erreur get process status', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }

    /**
     * Abandonner une inscription
     */
    public function abandonRegistration(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'session_token' => 'required|string|size:64',
            ]);

            $result = $this->registrationService->abandonRegistration($validated['session_token']);

            return response()->json([
                'success' => true,
                'message' => 'Inscription abandonnée avec succès'
            ]);

        } catch (RegistrationException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);

        } catch (\Exception $e) {
            Log::error('Erreur abandon registration', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur'
            ], 500);
        }
    }
}