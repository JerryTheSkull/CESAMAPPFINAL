<?php

namespace App\Services;

use App\Models\RegistrationProcess;
use App\Models\RegistrationStepData;
use App\Models\RegistrationAuditLog;
use App\Models\User;
use App\Exceptions\RegistrationException;
use App\Mail\VerificationCodeMail;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AdvancedRegistrationService
{
    private const SESSION_LIFETIME = 24;

    /**
     * Étape 1 : Informations personnelles
     */
    public function step1(?string $sessionToken, array $data): array
    {
        return DB::transaction(function () use ($data, $sessionToken) {
            // Valider les champs requis
            $requiredFields = ['nom_complet', 'email', 'password'];
            foreach ($requiredFields as $field) {
                if (!isset($data[$field]) || empty($data[$field])) {
                    throw new RegistrationException("Le champ $field est requis pour l'étape 1");
                }
            }

            // Créer ou récupérer le processus
            $process = $this->getOrCreateProcess($sessionToken);
            $sessionToken = $process->session_token;

            // Hasher le mot de passe
            $data['password_hash'] = Hash::make($data['password']);
            unset($data['password']);

            // Sauvegarder les données
            $this->saveStepData($process, 1, $data);
            $process->update([
                'user_email' => $data['email'],
                'current_step' => max($process->current_step, 1)
            ]);

            RegistrationAuditLog::logStepCompleted($process->id, 1, $data);

            return [
                'success' => true,
                'message' => 'Étape 1 complétée avec succès',
                'session_token' => $sessionToken,
                'current_step' => 1,
                'can_proceed' => true
            ];
        });
    }

    /**
     * Étape 2 : Éducation
     */
    public function step2(string $sessionToken, array $data): array
    {
        return DB::transaction(function () use ($sessionToken, $data) {
            $process = $this->getValidProcess($sessionToken);

            if ($process->current_step < 1) {
                throw new RegistrationException('Veuillez d\'abord compléter l\'étape 1');
            }

            // Valider les champs requis
            $requiredFields = ['ecole', 'filiere', 'niveau_etude', 'ville'];
            foreach ($requiredFields as $field) {
                if (!isset($data[$field]) || empty($data[$field])) {
                    throw new RegistrationException("Le champ $field est requis pour l'étape 2");
                }
            }

            $this->saveStepData($process, 2, $data);
            $process->update(['current_step' => max($process->current_step, 2)]);

            RegistrationAuditLog::logStepCompleted($process->id, 2, $data);

            return [
                'success' => true,
                'message' => 'Étape 2 complétée avec succès',
                'session_token' => $sessionToken,
                'current_step' => 2,
                'can_proceed' => true
            ];
        });
    }

    /**
     * Étape 3 : Profil académique
     */
    public function step3(string $sessionToken, array $data): array
    {
        return DB::transaction(function () use ($sessionToken, $data) {
            $process = $this->getValidProcess($sessionToken);

            if ($process->current_step < 2) {
                throw new RegistrationException('Veuillez d\'abord compléter l\'étape 2');
            }

            $this->saveStepData($process, 3, $data);
            $process->update(['current_step' => max($process->current_step, 3)]);

            RegistrationAuditLog::logStepCompleted($process->id, 3, $data);

            return [
                'success' => true,
                'message' => 'Étape 3 complétée avec succès',
                'session_token' => $sessionToken,
                'current_step' => 3,
                'can_proceed' => true
            ];
        });
    }

    /**
     * Étape 4 : AMCI + Envoi du code de vérification
     */
    public function step4(string $sessionToken, array $data): array
    {
        return DB::transaction(function () use ($sessionToken, $data) {
            $process = $this->getValidProcess($sessionToken);

            if ($process->current_step < 3) {
                throw new RegistrationException('Veuillez d\'abord compléter l\'étape 3');
            }

            // Renommer matricule_amci en code_amci si nécessaire
            if (isset($data['matricule_amci'])) {
                $data['code_amci'] = $data['matricule_amci'];
                unset($data['matricule_amci']);
            }

            $this->saveStepData($process, 4, $data);
            $process->update(['current_step' => max($process->current_step, 4)]);

            // Générer et sauvegarder le code de vérification
            $verificationCode = $this->generateVerificationCode();

            $metadata = $process->metadata ?? [];
            $metadata['verification_code'] = (string) $verificationCode;
            $metadata['verification_expires_at'] = now()->addMinutes(10)->toIso8601String();
            $metadata['verification_attempts'] = 0;
            $metadata['code_sent_at'] = now()->toIso8601String();

            $process->update(['metadata' => $metadata]);

            try {
                $step1Data = $this->getStepData($process, 1);
                $nomComplet = $step1Data['nom_complet'] ?? 'Utilisateur';

                // Envoyer l'email dans tous les environnements
                Mail::to($process->user_email)->send(new VerificationCodeMail($verificationCode, $nomComplet));

                // Logger pour debug (seulement en local)
                if (config('app.env') === 'local') {
                    Log::info('✅ STEP4 - Code de vérification généré et email envoyé', [
                        'email' => $process->user_email,
                        'code' => $verificationCode,
                        'expires_at' => $metadata['verification_expires_at'],
                        'session_token' => substr($sessionToken, 0, 8) . '...',
                        'process_id' => $process->id
                    ]);
                }

                RegistrationAuditLog::logStepCompleted($process->id, 4, array_merge($data, ['email_sent' => true]));
                RegistrationAuditLog::logCodeSent($process->id, 4);

                return [
                    'success' => true,
                    'message' => 'Étape 4 complétée. Un code de vérification a été envoyé à votre email.',
                    'session_token' => $sessionToken,
                    'current_step' => 4,
                    'can_proceed' => true,
                    'email_sent' => true,
                    'verification_expires_at' => $metadata['verification_expires_at'],
                    // Retourner le code seulement en environnement local pour faciliter les tests
                    'verification_code' => config('app.env') === 'local' ? $verificationCode : null
                ];
            } catch (\Exception $e) {
                Log::error('❌ STEP4 - Erreur envoi email', [
                    'session_token' => substr($sessionToken, 0, 8) . '...',
                    'email' => $process->user_email,
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString()
                ]);

                return [
                    'success' => false,
                    'message' => 'Étape 4 complétée, mais erreur lors de l\'envoi de l\'email: ' . $e->getMessage(),
                    'session_token' => $sessionToken,
                    'current_step' => 4,
                    'email_sent' => false,
                    'verification_code' => config('app.env') === 'local' ? $verificationCode : null
                ];
            }
        });
    }

    /**
     * Étape 5 : Vérification du code + Finalisation
     */
    public function step5(string $sessionToken, array $data): array
    {
        return DB::transaction(function () use ($sessionToken, $data) {
            $process = $this->getValidProcess($sessionToken);

            if ($process->current_step < 4) {
                throw new RegistrationException('Veuillez d\'abord compléter l\'étape 4');
            }

            $metadata = $process->metadata ?? [];

            if (!isset($metadata['verification_code']) || !isset($data['verification_code'])) {
                throw new RegistrationException('Aucun code de vérification trouvé');
            }

            if (isset($metadata['verification_expires_at']) && Carbon::parse($metadata['verification_expires_at'])->isPast()) {
                throw new RegistrationException('Le code de vérification a expiré');
            }

            $codeRecu = (string) trim($data['verification_code']);
            $codeStocke = (string) trim($metadata['verification_code']);

            if ($codeStocke !== $codeRecu) {
                $metadata['verification_attempts'] = ($metadata['verification_attempts'] ?? 0) + 1;
                $process->update(['metadata' => $metadata]);

                Log::warning('❌ STEP5 - Code incorrect', [
                    'code_reçu' => $codeRecu,
                    'code_attendu' => $codeStocke,
                    'tentatives' => $metadata['verification_attempts'],
                    'session_token' => substr($sessionToken, 0, 8) . '...'
                ]);

                if ($metadata['verification_attempts'] >= 3) {
                    throw new RegistrationException('Trop de tentatives incorrectes. Veuillez demander un nouveau code.');
                }

                throw new RegistrationException('Code de vérification incorrect. Tentatives: ' . $metadata['verification_attempts'] . '/3');
            }

            // Enregistrer les logs d'audit AVANT de créer l'utilisateur
            RegistrationAuditLog::logCodeVerified($process->id, 5);
            RegistrationAuditLog::logCompleted($process->id);

            // Code valide, créer l'utilisateur final
            $user = $this->createFinalUser($process);

            // Marquer le processus comme terminé
            $process->update([
                'status' => 'completed',
                'current_step' => 5
            ]);

            return [
                'success' => true,
                'message' => 'Félicitations ! Votre inscription est maintenant complète et en attente d\'approbation par un administrateur.',
                'user_verified' => true,
                'registration_status' => 'pending',
                'user_id' => $user->id
            ];
        });
    }

    /**
     * Renvoyer le code de vérification
     */
    public function resendVerificationCode(string $sessionToken): array
    {
        return DB::transaction(function () use ($sessionToken) {
            $process = $this->getValidProcess($sessionToken);

            if ($process->current_step < 4) {
                throw new RegistrationException('Veuillez d\'abord compléter l\'étape 4');
            }

            if ($process->status === 'completed') {
                throw new RegistrationException('Cette inscription est déjà terminée');
            }

            $verificationCode = $this->generateVerificationCode();

            $metadata = $process->metadata ?? [];
            $metadata['verification_code'] = (string) $verificationCode;
            $metadata['verification_expires_at'] = now()->addMinutes(10)->toIso8601String();
            $metadata['verification_attempts'] = 0;
            $metadata['code_sent_at'] = now()->toIso8601String();

            $process->update(['metadata' => $metadata]);

            try {
                $step1Data = $this->getStepData($process, 1);
                $nomComplet = $step1Data['nom_complet'] ?? 'Utilisateur';

                // Envoyer l'email dans tous les environnements
                Mail::to($process->user_email)->send(new VerificationCodeMail($verificationCode, $nomComplet));

                if (config('app.env') === 'local') {
                    Log::info('✅ RESEND - Nouveau code généré et email envoyé', [
                        'email' => $process->user_email,
                        'code' => $verificationCode,
                        'expires_at' => $metadata['verification_expires_at'],
                        'session_token' => substr($sessionToken, 0, 8) . '...'
                    ]);
                }

                RegistrationAuditLog::logCodeSent($process->id, 4);

                return [
                    'success' => true,
                    'message' => 'Un nouveau code de vérification a été envoyé à votre email.',
                    'verification_expires_at' => $metadata['verification_expires_at'],
                    'verification_code' => config('app.env') === 'local' ? $verificationCode : null
                ];
            } catch (\Exception $e) {
                Log::error('❌ RESEND - Erreur envoi email', [
                    'session_token' => substr($sessionToken, 0, 8) . '...',
                    'email' => $process->user_email,
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString()
                ]);

                return [
                    'success' => false,
                    'message' => 'Erreur lors de l\'envoi de l\'email: ' . $e->getMessage(),
                    'verification_code' => config('app.env') === 'local' ? $verificationCode : null
                ];
            }
        });
    }

    /**
     * Abandonner une inscription
     */
    public function abandonRegistration(string $sessionToken): bool
    {
        return DB::transaction(function () use ($sessionToken) {
            $process = $this->getValidProcess($sessionToken);

            $process->update(['status' => 'abandoned']);

            RegistrationAuditLog::create([
                'process_id' => $process->id,
                'action' => 'abandoned',
                'step_number' => $process->current_step,
                'ip_address' => request()->ip(),
                'user_agent' => request()->userAgent()
            ]);

            return true;
        });
    }

    /**
     * Récupérer les données d'une étape pour navigation arrière (AVEC masquage)
     */
    public function getStepData(RegistrationProcess $process, int $stepNumber): array
    {
        $stepData = RegistrationStepData::where('process_id', $process->id)
            ->where('step_number', $stepNumber)
            ->first();

        if (!$stepData) {
            return [];
        }

        $data = $stepData->data;

        // Masquer les données sensibles SEULEMENT pour l'API publique
        if ($stepNumber === 1 && isset($data['password_hash'])) {
            unset($data['password_hash']);
        }

        return $data;
    }

    /**
     * Vérifier et récupérer un processus valide
     */
    public function getValidProcess(string $sessionToken): RegistrationProcess
    {
        $process = RegistrationProcess::where('session_token', $sessionToken)
            ->where('expires_at', '>', now())
            ->where('status', 'in_progress')
            ->first();

        if (!$process) {
            throw new RegistrationException('Session invalide ou expirée');
        }

        $process->update(['expires_at' => now()->addHours(self::SESSION_LIFETIME)]);

        return $process;
    }

    // === MÉTHODES PRIVÉES ===

    /**
     * Créer ou récupérer un processus d'inscription
     */
    private function getOrCreateProcess(?string $sessionToken): RegistrationProcess
    {
        if ($sessionToken) {
            $process = RegistrationProcess::where('session_token', $sessionToken)
                ->where('expires_at', '>', now())
                ->where('status', 'in_progress')
                ->first();

            if ($process) {
                $process->update(['expires_at' => now()->addHours(self::SESSION_LIFETIME)]);
                return $process;
            }
        }

        return RegistrationProcess::create([
            'session_token' => Str::random(64),
            'current_step' => 0,
            'total_steps' => 5,
            'status' => 'in_progress',
            'expires_at' => now()->addHours(self::SESSION_LIFETIME)
        ]);
    }

    /**
     * Sauvegarder les données d'une étape
     */
    private function saveStepData(RegistrationProcess $process, int $stepNumber, array $data): void
    {
        RegistrationStepData::updateOrCreate(
            ['process_id' => $process->id, 'step_number' => $stepNumber],
            ['data' => $data]
        );
    }

    /**
     * Créer l'utilisateur final
     */
    private function createFinalUser(RegistrationProcess $process): User
    {
        return DB::transaction(function () use ($process) {
            // Récupérer les données DIRECTEMENT depuis la base sans masquage
            $step1Data = $this->getRawStepData($process, 1);
            $step2Data = $this->getRawStepData($process, 2);
            $step3Data = $this->getRawStepData($process, 3);
            $step4Data = $this->getRawStepData($process, 4);

            // Valider les champs requis
            if (!isset($step1Data['nom_complet']) || empty($step1Data['nom_complet'])) {
                throw new RegistrationException('Le champ nom_complet est requis pour l\'étape 1');
            }
            if (!isset($step1Data['email']) || empty($step1Data['email'])) {
                throw new RegistrationException('Le champ email est requis pour l\'étape 1');
            }
            if (!isset($step1Data['password_hash']) || empty($step1Data['password_hash'])) {
                throw new RegistrationException('Le mot de passe est requis pour l\'étape 1');
            }

            $userData = [
                'registration_process_id' => $process->id,
                'nom_complet' => $step1Data['nom_complet'],
                'email' => $step1Data['email'],
                'password' => $step1Data['password_hash'],
                'telephone' => $step1Data['telephone'] ?? null,
                'nationalite' => $step1Data['nationalite'] ?? null,
                'ecole' => $step2Data['ecole'] ?? null,
                'filiere' => $step2Data['filiere'] ?? null,
                'niveau_etude' => $step2Data['niveau_etude'] ?? null,
                'ville' => $step2Data['ville'] ?? null,
                'cv_url' => $step3Data['cv_url'] ?? null,
                'competences' => $step3Data['competences'] ?? null,
                'projects' => $step3Data['projects'] ?? null,
                'code_amci' => $step4Data['code_amci'] ?? null,
                'affilie_amci' => $step4Data['affilie_amci'] ?? false,
                'registration_status' => 'pending',
                'registration_completed_at' => now(),
                'email_verified_at' => now(),
                'is_verified' => true,
                'is_approved' => false,
                'verification_token' => null,
                'verification_code_expires_at' => null
            ];

            $user = User::create($userData);

            // Nettoyer les données temporaires
            RegistrationStepData::where('process_id', $process->id)->delete();
            $process->delete();

            return $user;
        });
    }

    /**
     * Récupérer les données brutes d'une étape SANS masquage (pour usage interne)
     */
    private function getRawStepData(RegistrationProcess $process, int $stepNumber): array
    {
        $stepData = RegistrationStepData::where('process_id', $process->id)
            ->where('step_number', $stepNumber)
            ->first();

        if (!$stepData) {
            return [];
        }

        return $stepData->data; // Retourne les données SANS masquage
    }

    /**
     * Générer un code de vérification à 6 chiffres
     */
    private function generateVerificationCode(): string
    {
        return sprintf('%06d', mt_rand(100000, 999999));
    }
}