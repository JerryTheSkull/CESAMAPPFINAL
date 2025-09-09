<?php

namespace App\Http\Controllers\profil;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Ramsey\Uuid\Uuid;

class UserProfileController extends Controller
{
    // Constantes pour les listes déroulantes
    private const VILLES_MAROC = [
        'Agadir', 'Al Hoceima', 'Azrou', 'Beni Mellal', 'Berrechid',
        'Casablanca', 'Chefchaouen', 'Dakhla', 'El Jadida', 'Errachidia',
        'Essaouira', 'Fès', 'Guelmim', 'Ifrane', 'Kénitra', 'Khouribga',
        'Ksar El Kebir', 'Laâyoune', 'Larache', 'Marrakech', 'Meknès',
        'Mohammedia', 'Nador', 'Ouarzazate', 'Oujda', 'Rabat', 'Safi',
        'Salé', 'Settat', 'Sidi Ifni', 'Tanger', 'Taourirt', 'Taroudant',
        'Taza', 'Témara', 'Tétouan', 'Tiznit'
    ];

    private const NIVEAUX_ETUDE = [
        'Licence 1', 'Licence 2', 'Licence 3', 'Master 1', 'Master 2',
        'Doctorat', 'Ingénieur', 'DUT', 'BTS', 'Autre'
    ];

    /**
     * Formate les réponses JSON de manière standardisée
     * @param bool $success
     * @param string $message
     * @param mixed $data
     * @param int $status
     * @param mixed $errors
     * @return \Illuminate\Http\JsonResponse
     */
    private function apiResponse(bool $success, string $message, $data = null, int $status = 200, $errors = null)
    {
        $response = [
            'success' => $success,
            'message' => $message,
        ];

        if ($data !== null) {
            $response['data'] = $data;
        }

        if ($errors !== null) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $status);
    }

    /**
     * Récupère le profil complet avec projets JSON
     * Route: GET /api/profile
     */
    public function show()
    {
        try {
            /** @var User $user */
            $user = Auth::user();

            if (!$user) {
                return $this->apiResponse(
                    success: false,
                    message: 'Utilisateur non trouvé',
                    status: 404
                );
            }

            // Les projets sont maintenant dans un champ JSON
            $projects = $user->projects ?? [];

            Log::debug('✅ Profil récupéré pour user ID: ' . $user->id . ' avec ' . count($projects) . ' projets');

            return $this->apiResponse(
                success: true,
                message: 'Profil récupéré avec succès',
                data: [
                    'user' => [
                        'id' => $user->id,
                        'nom_complet' => $user->nom_complet,
                        'email' => $user->email,
                        'telephone' => $user->telephone,
                        'nationalite' => $user->nationalite,
                        'ecole' => $user->ecole,
                        'filiere' => $user->filiere,
                        'niveau_etude' => $user->niveau_etude,
                        'ville' => $user->ville,
                        'affilie_amci' => $user->affilie_amci,
                        'code_amci' => $user->code_amci,
                        'matricule_amci' => $user->matricule_amci,
                        'photo_path' => $user->profile_photo_url,
                        'cv_url' => $user->cv_url,
                        'has_cv' => $user->hasCV(),
                        'has_profile_photo' => $user->hasProfilePhoto(),
                        'competences' => $user->competences ?? [],
                        'projects' => array_values($projects), // Réindexer le tableau
                        'is_verified' => $user->is_verified,
                        'is_approved' => $user->is_approved,
                        'email_verified_at' => $user->email_verified_at?->toIso8601String(),
                        'status' => $user->status,
                        'created_at' => $user->created_at?->toIso8601String(),
                        'updated_at' => $user->updated_at?->toIso8601String(),
                    ]
                ]
            );

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la récupération du profil: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la récupération du profil',
                status: 500
            );
        }
    }

    /**
     * Ajouter un projet au champ JSON
     * Route: POST /api/profile/projects
     */
    public function addProject(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:200',
                'description' => 'required|string|max:1000',
                'link' => 'nullable|url|max:255',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Données invalides',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();

            DB::beginTransaction();

            try {
                $project = [
                    'id' => Uuid::uuid4()->toString(), // Générer un ID unique
                    'title' => $request->title,
                    'description' => $request->description,
                    'link' => $request->link,
                    'created_at' => now()->toIso8601String(),
                ];

                $user->addProject($project);
                $user->save();

                DB::commit();

                Log::debug('✅ Projet ajouté au JSON pour user ID: ' . $user->id . ', project ID: ' . $project['id']);

                return $this->apiResponse(
                    success: true,
                    message: 'Projet ajouté avec succès',
                    data: [
                        'project' => $project,
                        'projects_count' => count($user->projects ?? [])
                    ],
                    status: 201
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de l\'ajout du projet JSON: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de l\'ajout du projet',
                status: 500
            );
        }
    }

    /**
     * Récupère tous les projets depuis le champ JSON
     * Route: GET /api/profile/projects
     */
    public function getProjects(Request $request)
    {
        try {
            /** @var User $user */
            $user = Auth::user();

            $projects = $user->projects ?? [];

            Log::debug('✅ Récupération de ' . count($projects) . ' projets JSON pour user ID: ' . $user->id);

            return $this->apiResponse(
                success: true,
                message: 'Projets récupérés avec succès',
                data: [
                    'projects' => array_values($projects),
                    'projects_count' => count($projects)
                ]
            );

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la récupération des projets JSON: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la récupération des projets',
                status: 500
            );
        }
    }

    /**
     * Met à jour un projet dans le champ JSON
     * Route: PUT /api/profile/projects/{projectId}
     */
    public function updateProject(Request $request, $projectId)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:200',
                'description' => 'required|string|max:1000',
                'link' => 'nullable|url|max:255',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Données invalides',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();

            DB::beginTransaction();

            try {
                $updated = $user->updateProject($projectId, [
                    'id' => $projectId,
                    'title' => $request->title,
                    'description' => $request->description,
                    'link' => $request->link,
                    'created_at' => $user->getProject($projectId)['created_at'] ?? now()->toIso8601String(),
                ]);

                if (!$updated) {
                    return $this->apiResponse(
                        success: false,
                        message: 'Projet non trouvé',
                        status: 404
                    );
                }

                $user->save();
                DB::commit();

                Log::debug('✅ Projet JSON mis à jour pour user ID: ' . $user->id . ', project ID: ' . $projectId);

                return $this->apiResponse(
                    success: true,
                    message: 'Projet mis à jour avec succès',
                    data: [
                        'project' => $user->getProject($projectId)
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la mise à jour du projet JSON: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la mise à jour du projet',
                status: 500
            );
        }
    }

    /**
     * Supprime un projet du champ JSON
     * Route: DELETE /api/profile/projects/{projectId}
     */
    public function deleteProject($projectId)
    {
        try {
            /** @var User $user */
            $user = Auth::user();

            DB::beginTransaction();

            try {
                $deleted = $user->removeProject($projectId);

                if (!$deleted) {
                    return $this->apiResponse(
                        success: false,
                        message: 'Projet non trouvé',
                        status: 404
                    );
                }

                $user->save();
                DB::commit();

                Log::debug('✅ Projet JSON supprimé pour user ID: ' . $user->id . ', project ID: ' . $projectId);

                return $this->apiResponse(
                    success: true,
                    message: 'Projet supprimé avec succès',
                    data: [
                        'remaining_projects_count' => count($user->projects ?? [])
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la suppression du projet JSON: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la suppression du projet',
                status: 500
            );
        }
    }

    /**
     * Obtient un projet spécifique par son ID
     * Route: GET /api/profile/projects/{projectId}
     */
    public function getProject($projectId)
    {
        try {
            /** @var User $user */
            $user = Auth::user();

            $project = $user->getProject($projectId);

            if (!$project) {
                return $this->apiResponse(
                    success: false,
                    message: 'Projet non trouvé',
                    status: 404
                );
            }

            return $this->apiResponse(
                success: true,
                message: 'Projet récupéré avec succès',
                data: [
                    'project' => $project
                ]
            );

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la récupération du projet JSON: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la récupération du projet',
                status: 500
            );
        }
    }

    /**
     * Met à jour le profil utilisateur
     * Route: PUT /api/profile
     */
    public function update(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'nom_complet' => 'sometimes|string|max:255',
                'email' => 'sometimes|email|unique:users,email,' . Auth::id(),
                'telephone' => 'nullable|string|max:20|regex:/^\+?[0-9\s]{8,15}$/',
                'nationalite' => 'nullable|string|max:100',
                'ecole' => 'nullable|string|max:200',
                'filiere' => 'nullable|string|max:200',
                'niveau_etude' => 'nullable|string|in:' . implode(',', self::NIVEAUX_ETUDE),
                'ville' => 'nullable|string|in:' . implode(',', self::VILLES_MAROC),
                'affilie_amci' => 'nullable|boolean',
                'code_amci' => 'nullable|string|max:50|required_if:affilie_amci,true',
                'matricule_amci' => 'nullable|string|max:50',
                'password' => 'nullable|string|min:8',
                'password_confirmation' => 'nullable|string|same:password|required_with:password',
            ], [
                'telephone.regex' => 'Le numéro de téléphone doit être valide (8 à 15 chiffres, peut inclure + et espaces).',
                'code_amci.required_if' => 'Le code AMCI est requis si vous êtes affilié AMCI.',
                'email.unique' => 'Cette adresse email est déjà utilisée.',
                'password.min' => 'Le mot de passe doit contenir au moins 8 caractères.',
                'password_confirmation.same' => 'La confirmation du mot de passe ne correspond pas.',
                'ville.in' => 'La ville sélectionnée n\'est pas valide.',
                'niveau_etude.in' => 'Le niveau d\'étude sélectionné n\'est pas valide.',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Données invalides',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $updated = false;

            DB::beginTransaction();

            try {
                $fillableFields = [
                    'nom_complet', 'email', 'telephone', 'nationalite',
                    'ecole', 'filiere', 'niveau_etude', 'ville'
                ];

                foreach ($fillableFields as $field) {
                    if ($request->has($field) && $user->{$field} !== $request->{$field}) {
                        $user->{$field} = $request->{$field};
                        $updated = true;
                    }
                }

                if ($request->has('affilie_amci') && $user->affilie_amci !== $request->affilie_amci) {
                    $user->affilie_amci = $request->affilie_amci;
                    if (!$request->affilie_amci) {
                        $user->code_amci = null;
                        $user->matricule_amci = null;
                    }
                    $updated = true;
                }

                if ($request->has('code_amci') && $user->affilie_amci && $user->code_amci !== $request->code_amci) {
                    $user->code_amci = $request->code_amci;
                    $updated = true;
                }

                if ($request->has('matricule_amci') && $user->affilie_amci && $user->matricule_amci !== $request->matricule_amci) {
                    $user->matricule_amci = $request->matricule_amci;
                    $updated = true;
                }

                if ($request->has('password') && !empty($request->password)) {
                    $user->password = Hash::make($request->password);
                    $updated = true;
                }

                if ($updated) {
                    $user->save();
                    Log::debug('✅ Profil mis à jour pour user ID: ' . $user->id);
                }

                DB::commit();

                return $this->apiResponse(
                    success: true,
                    message: 'Profil mis à jour avec succès',
                    data: [
                        'user' => [
                            'id' => $user->id,
                            'nom_complet' => $user->nom_complet,
                            'email' => $user->email,
                            'telephone' => $user->telephone,
                            'nationalite' => $user->nationalite,
                            'ecole' => $user->ecole,
                            'filiere' => $user->filiere,
                            'niveau_etude' => $user->niveau_etude,
                            'ville' => $user->ville,
                            'affilie_amci' => $user->affilie_amci,
                            'code_amci' => $user->code_amci,
                            'matricule_amci' => $user->matricule_amci,
                            'updated_at' => $user->updated_at?->toIso8601String(),
                        ]
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la mise à jour du profil: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la mise à jour du profil',
                status: 500
            );
        }
    }

    /**
     * Met à jour les informations personnelles
     * Route: PUT /api/profile/personal-info
     */
    public function updatePersonalInfo(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'telephone' => 'nullable|string|max:20|regex:/^\+?[0-9\s]{8,15}$/',
                'ville' => 'nullable|string|in:' . implode(',', self::VILLES_MAROC),
                'affilie_amci' => 'nullable|boolean',
                'code_amci' => 'nullable|string|max:50|required_if:affilie_amci,true',
                'matricule_amci' => 'nullable|string|max:50',
            ], [
                'telephone.regex' => 'Le numéro de téléphone doit être valide (8 à 15 chiffres, peut inclure + et espaces).',
                'code_amci.required_if' => 'Le code AMCI est requis si vous êtes affilié AMCI.',
                'ville.in' => 'La ville sélectionnée n\'est pas valide.',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Données invalides',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $updated = false;

            DB::beginTransaction();

            try {
                if ($request->has('telephone') && $user->telephone !== $request->telephone) {
                    $user->telephone = $request->telephone;
                    $updated = true;
                }

                if ($request->has('ville') && $user->ville !== $request->ville) {
                    $user->ville = $request->ville;
                    $updated = true;
                }

                if ($request->has('affilie_amci') && $user->affilie_amci !== $request->affilie_amci) {
                    $user->affilie_amci = $request->affilie_amci;
                    if (!$request->affilie_amci) {
                        $user->code_amci = null;
                        $user->matricule_amci = null;
                    }
                    $updated = true;
                }

                if ($request->has('code_amci') && $user->affilie_amci && $user->code_amci !== $request->code_amci) {
                    $user->code_amci = $request->code_amci;
                    $updated = true;
                }

                if ($request->has('matricule_amci') && $user->affilie_amci && $user->matricule_amci !== $request->matricule_amci) {
                    $user->matricule_amci = $request->matricule_amci;
                    $updated = true;
                }

                if ($updated) {
                    $user->save();
                    Log::debug('✅ Mise à jour personnelle réussie pour user ID: ' . $user->id);
                }

                DB::commit();

                return $this->apiResponse(
                    success: true,
                    message: 'Informations personnelles mises à jour avec succès',
                    data: [
                        'telephone' => $user->telephone,
                        'ville' => $user->ville,
                        'affilie_amci' => $user->affilie_amci,
                        'code_amci' => $user->code_amci,
                        'matricule_amci' => $user->matricule_amci,
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la mise à jour des informations personnelles: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la mise à jour',
                status: 500
            );
        }
    }

    /**
     * Met à jour les informations académiques
     * Route: PUT /api/profile/academic-info
     */
    public function updateAcademicInfo(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'ecole' => 'nullable|string|max:200',
                'filiere' => 'nullable|string|max:200',
                'niveau_etude' => 'nullable|string|in:' . implode(',', self::NIVEAUX_ETUDE),
            ], [
                'niveau_etude.in' => 'Le niveau d\'étude sélectionné n\'est pas valide.',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Données invalides',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $updated = false;

            DB::beginTransaction();

            try {
                if ($request->has('ecole') && $user->ecole !== $request->ecole) {
                    $user->ecole = $request->ecole;
                    $updated = true;
                }

                if ($request->has('filiere') && $user->filiere !== $request->filiere) {
                    $user->filiere = $request->filiere;
                    $updated = true;
                }

                if ($request->has('niveau_etude') && $user->niveau_etude !== $request->niveau_etude) {
                    $user->niveau_etude = $request->niveau_etude;
                    $updated = true;
                }

                if ($updated) {
                    $user->save();
                    Log::debug('✅ Mise à jour académique réussie pour user ID: ' . $user->id);
                }

                DB::commit();

                return $this->apiResponse(
                    success: true,
                    message: 'Informations académiques mises à jour avec succès',
                    data: [
                        'ecole' => $user->ecole,
                        'filiere' => $user->filiere,
                        'niveau_etude' => $user->niveau_etude,
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la mise à jour des informations académiques: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la mise à jour',
                status: 500
            );
        }
    }

    /**
     * Upload de la photo de profil
     * Route: POST /api/profile/photo
     */
    public function uploadProfilePhoto(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'photo' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
            ], [
                'photo.required' => 'Une photo est requise.',
                'photo.image' => 'Le fichier doit être une image.',
                'photo.mimes' => 'L\'image doit être de type jpeg, png, jpg ou gif.',
                'photo.max' => 'L\'image ne doit pas dépasser 2MB.'
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Fichier invalide',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $oldPath = $user->profile_image_url;

            DB::beginTransaction();

            try {
                $newPath = $request->file('photo')->store('profiles', 'public');
                $user->profile_image_url = $newPath;
                $user->save();

                if ($oldPath && Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }

                DB::commit();

                Log::debug('✅ Photo de profil mise à jour pour user ID: ' . $user->id);

                return $this->apiResponse(
                    success: true,
                    message: 'Photo de profil mise à jour avec succès',
                    data: [
                        'profile_photo_url' => asset('storage/' . $newPath),
                        'has_profile_photo' => true
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de l\'upload de la photo de profil: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de l\'upload de la photo',
                status: 500
            );
        }
    }

    /**
     * Suppression de la photo de profil
     * Route: DELETE /api/profile/photo
     */
    public function deleteProfilePhoto()
    {
        try {
            /** @var User $user */
            $user = Auth::user();

            DB::beginTransaction();

            try {
                if ($user->profile_image_url && Storage::disk('public')->exists($user->profile_image_url)) {
                    Storage::disk('public')->delete($user->profile_image_url);
                }

                $user->profile_image_url = null;
                $user->save();

                DB::commit();

                Log::debug('✅ Photo de profil supprimée pour user ID: ' . $user->id);

                return $this->apiResponse(
                    success: true,
                    message: 'Photo de profil supprimée avec succès',
                    data: [
                        'has_profile_photo' => false
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la suppression de la photo de profil: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la suppression de la photo',
                status: 500
            );
        }
    }

    /**
     * Ajoute une nouvelle compétence
     * Route: POST /api/profile/skills
     */
    public function addSkill(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'skill' => 'required|string|max:100|regex:/^[a-zA-Z0-9\s]+$/',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Compétence invalide',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $skillName = strtolower(trim($request->skill));
            $competences = $user->competences ?? [];

            if (in_array($skillName, $competences)) {
                return $this->apiResponse(
                    success: false,
                    message: 'Cette compétence existe déjà',
                    status: 409
                );
            }

            DB::beginTransaction();

            try {
                $competences[] = $skillName;
                $user->competences = $competences;
                $user->save();

                Log::debug('✅ Compétence ajoutée pour user ID: ' . $user->id . ', skill: ' . $skillName);

                DB::commit();

                return $this->apiResponse(
                    success: true,
                    message: 'Compétence ajoutée avec succès',
                    data: [
                        'skill' => $skillName,
                        'competences' => $user->competences
                    ],
                    status: 201
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de l\'ajout de la compétence: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de l\'ajout de la compétence',
                status: 500
            );
        }
    }

    /**
     * Met à jour toutes les compétences
     * Route: PUT /api/profile/skills
     */
    public function updateAllSkills(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'skills' => 'required|array',
                'skills.*' => 'string|max:100|regex:/^[a-zA-Z0-9\s]+$/',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Compétences invalides',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $skills = array_map('strtolower', array_map('trim', $request->skills));
            $skills = array_filter($skills, fn($skill) => !empty($skill));
            $skills = array_unique($skills);

            DB::beginTransaction();

            try {
                $user->competences = array_values($skills);
                $user->save();

                Log::debug('✅ Toutes les compétences mises à jour pour user ID: ' . $user->id);

                DB::commit();

                return $this->apiResponse(
                    success: true,
                    message: 'Compétences mises à jour avec succès',
                    data: [
                        'competences' => $user->competences
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la mise à jour des compétences: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la mise à jour des compétences',
                status: 500
            );
        }
    }

    /**
     * Supprime une compétence
     * Route: DELETE /api/profile/skills
     */
    public function removeSkill(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'skill' => 'required|string',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Paramètre invalide',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $skillToRemove = strtolower(trim($request->skill));
            $competences = $user->competences ?? [];

            $newCompetences = array_filter($competences, fn($skill) => $skill !== $skillToRemove);

            if (count($newCompetences) === count($competences)) {
                return $this->apiResponse(
                    success: false,
                    message: 'Compétence non trouvée',
                    status: 404
                );
            }

            DB::beginTransaction();

            try {
                $user->competences = array_values($newCompetences);
                $user->save();

                Log::debug('✅ Compétence supprimée pour user ID: ' . $user->id . ', skill: ' . $skillToRemove);

                DB::commit();

                return $this->apiResponse(
                    success: true,
                    message: 'Compétence supprimée avec succès',
                    data: [
                        'competences' => $user->competences
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la suppression de la compétence: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la suppression de la compétence',
                status: 500
            );
        }
    }

    /**
     * Upload du CV
     * Route: POST /api/profile/cv
     */
    public function uploadCV(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'cv' => 'required|file|mimes:pdf|max:5120'
            ], [
                'cv.required' => 'Un fichier CV est requis.',
                'cv.file' => 'Le CV doit être un fichier.',
                'cv.mimes' => 'Le CV doit être un fichier PDF.',
                'cv.max' => 'Le CV ne doit pas dépasser 5MB.'
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Fichier invalide',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();
            $oldPath = $user->cv_storage_path;

            DB::beginTransaction();

            try {
                $filename = 'cv_' . $user->id . '_' . time() . '.pdf';
                $newPath = $request->file('cv')->storeAs('cvs', $filename, 'public');
                $user->cv_url = $newPath;
                $user->save();

                if ($oldPath && Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }

                DB::commit();

                Log::debug('✅ CV mis à jour pour user ID: ' . $user->id);

                return $this->apiResponse(
                    success: true,
                    message: 'CV mis à jour avec succès',
                    data: [
                        'cv_url' => asset('storage/' . $newPath),
                        'has_cv' => true,
                        'filename' => $filename
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de l\'upload du CV: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de l\'upload du CV',
                status: 500
            );
        }
    }

    /**
     * Suppression du CV
     * Route: DELETE /api/profile/cv
     */
    public function deleteCV()
    {
        try {
            /** @var User $user */
            $user = Auth::user();

            DB::beginTransaction();

            try {
                if ($user->cv_storage_path && Storage::disk('public')->exists($user->cv_storage_path)) {
                    Storage::disk('public')->delete($user->cv_storage_path);
                }

                $user->cv_url = null;
                $user->save();

                DB::commit();

                Log::debug('✅ CV supprimé pour user ID: ' . $user->id);

                return $this->apiResponse(
                    success: true,
                    message: 'CV supprimé avec succès',
                    data: [
                        'has_cv' => false
                    ]
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la suppression du CV: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la suppression du CV',
                status: 500
            );
        }
    }

    /**
     * Téléchargement du CV
     * Route: GET /api/profile/cv/download
     */
    public function downloadCV()
    {
        try {
            /** @var User $user */
            $user = Auth::user();

            if (!$user->hasCV()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Aucun CV trouvé',
                    status: 404
                );
            }

            $path = $user->cv_storage_path;

            if (!Storage::disk('public')->exists($path)) {
                return $this->apiResponse(
                    success: false,
                    message: 'Fichier CV introuvable',
                    status: 404
                );
            }

            $fullPath = storage_path('app/public/' . $path);
            return response()->download($fullPath, 'CV_' . $user->nom_complet . '.pdf');

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors du téléchargement du CV: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors du téléchargement du CV',
                status: 500
            );
        }
    }

    /**
     * Supprime le compte utilisateur
     * Route: DELETE /api/profile
     */
    public function destroy(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'password' => 'required|string',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(
                    success: false,
                    message: 'Mot de passe requis',
                    errors: $validator->errors(),
                    status: 422
                );
            }

            /** @var User $user */
            $user = Auth::user();

            if (!Hash::check($request->password, $user->password)) {
                return $this->apiResponse(
                    success: false,
                    message: 'Mot de passe incorrect',
                    status: 401
                );
            }

            DB::beginTransaction();

            try {
                if ($user->profile_image_url && Storage::disk('public')->exists($user->profile_image_url)) {
                    Storage::disk('public')->delete($user->profile_image_url);
                }

                if ($user->cv_storage_path && Storage::disk('public')->exists($user->cv_storage_path)) {
                    Storage::disk('public')->delete($user->cv_storage_path);
                }

                $user->tokens()->delete();
                $user->delete();

                Log::info('✅ Compte utilisateur supprimé: ' . $user->email);

                DB::commit();

                return $this->apiResponse(
                    success: true,
                    message: 'Compte supprimé avec succès'
                );

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('❌ Erreur lors de la suppression du compte: ' . $e->getMessage());
            return $this->apiResponse(
                success: false,
                message: 'Erreur lors de la suppression du compte',
                status: 500
            );
        }
    }

    /**
     * Obtenir les listes déroulantes pour le frontend
     * Route: GET /api/profile/options
     */
    public function getOptions()
    {
        return $this->apiResponse(
            success: true,
            message: 'Options récupérées avec succès',
            data: [
                'villes' => self::VILLES_MAROC,
                'niveaux_etude' => self::NIVEAUX_ETUDE,
            ]
        );
    }
}