<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Spatie\Permission\Traits\HasRoles;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Exception;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles, SoftDeletes;

    protected $fillable = [
        'nom_complet',
        'email',
        'password',
        'telephone',
        'nationalite',
        'ecole',
        'filiere',
        'niveau_etude',
        'ville',
        'cv_url',
        'profile_image_url',
        'competences',
        'affilie_amci',
        'code_amci',
        'matricule_amci',
        'verification_token',
        'verification_code_expires_at',
        'is_verified',
        'is_approved',
        'email_verified_at',
        'status',
        'registration_status',
        'registration_completed_at',
        'registration_process_id',
        'projects', // Champ JSON pour les projets
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'verification_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'competences' => 'json',
        'projects' => 'json',
        'is_verified' => 'boolean',
        'is_approved' => 'boolean',
        'affilie_amci' => 'boolean',
        'verification_code_expires_at' => 'datetime',
        'registration_completed_at' => 'datetime',
    ];

    // ===============================
    // Méthodes pour gérer les projets
    // ===============================

    public function addProject(array $projectData): void
    {
        $projects = $this->projects ?? [];
        $newProject = [
            'id' => uniqid(),
            'title' => $projectData['title'],
            'description' => $projectData['description'],
            'link' => $projectData['link'] ?? null,
            'created_at' => now()->toIso8601String(),
        ];
        $projects[] = $newProject;
        $this->projects = $projects;
        $this->save();
    }

    public function updateProject(string $projectId, array $projectData): bool
    {
        $projects = $this->projects ?? [];
        foreach ($projects as &$project) {
            if ($project['id'] === $projectId) {
                $project = array_merge($project, $projectData);
                $project['updated_at'] = now()->toIso8601String();
                $this->projects = $projects;
                $this->save();
                return true;
            }
        }
        return false;
    }

    public function removeProject(string $projectId): bool
    {
        $projects = $this->projects ?? [];
        $filteredProjects = array_filter($projects, fn($project) => $project['id'] !== $projectId);
        if (count($filteredProjects) !== count($projects)) {
            $this->projects = array_values($filteredProjects);
            $this->save();
            return true;
        }
        return false;
    }

    public function getProject(string $projectId): ?array
    {
        $projects = $this->projects ?? [];
        foreach ($projects as $project) {
            if ($project['id'] === $projectId) {
                return $project;
            }
        }
        return null;
    }

    // ===============================
    // Relations
    // ===============================

    public function legacyProjects()
    {
        return $this->hasMany(Project::class);
    }

    public function profile()
    {
        return $this->hasOne(UserProfile::class);
    }

    public function reports()
    {
        return $this->hasMany(Report::class);
    }

    public function processedReports()
    {
        return $this->hasMany(Report::class, 'admin_id');
    }

    public function likedVideos()
    {
        return $this->belongsToMany(Video::class, 'likes')->withTimestamps();
    }

    public function likes()
    {
        return $this->hasMany(Like::class);
    }

    public function applications()
    {
        return $this->hasMany(Application::class);
    }

    public function appliedOffers()
    {
        return $this->belongsToMany(Offer::class, 'applications')->withTimestamps();
    }

    // ===============================
    // Accessors & Mutators
    // ===============================

    public function setMatriculeAmciAttribute($value): void
    {
        $this->attributes['matricule_amci'] = $value;
        if (empty($this->attributes['code_amci'])) {
            $this->attributes['code_amci'] = $value;
        }
    }

    public function setCodeAmciAttribute($value): void
    {
        $this->attributes['code_amci'] = $value;
        if (empty($this->attributes['matricule_amci'])) {
            $this->attributes['matricule_amci'] = $value;
        }
    }

    public function getCompetencesAttribute($value): array
    {
        if (is_string($value)) {
            $decoded = json_decode($value, true);
            return is_array($decoded) ? $decoded : [];
        }
        return is_array($value) ? $value : [];
    }

    public function setCompetencesAttribute($value): void
    {
        $this->attributes['competences'] = is_array($value) ? json_encode($value) : $value;
    }

    public function getCvUrlAttribute($value): ?string
    {
        if (empty($value)) return null;
        return str_starts_with($value, 'http') ? $value : asset('storage/' . $value);
    }

    public function getProfilePhotoUrlAttribute(): ?string
    {
        if (empty($this->profile_image_url)) return null;
        return str_starts_with($this->profile_image_url, 'http') ? $this->profile_image_url : asset('storage/' . $this->profile_image_url);
    }

    public function getCvStoragePathAttribute(): ?string
    {
        return $this->attributes['cv_url'] ?? null;
    }

    // ===============================
    // Méthodes utilitaires
    // ===============================

    public function hasCV(): bool
    {
        if (empty($this->cv_url)) return false;
        $path = str_starts_with($this->cv_url, 'http') ? str_replace(asset('storage/'), '', $this->cv_url) : $this->cv_url;
        return Storage::disk('public')->exists($path);
    }

    public function hasProfilePhoto(): bool
    {
        if (empty($this->profile_image_url)) return false;
        return Storage::disk('public')->exists($this->profile_image_url);
    }

    public function generateVerificationCode(): string
    {
        try {
            $code = sprintf('%06d', mt_rand(100000, 999999));
            $this->update([
                'verification_token' => $code,
                'verification_code_expires_at' => now()->addMinutes(10),
            ]);
            return $code;
        } catch (Exception $e) {
            Log::error('Erreur lors de la génération du code de vérification pour l\'utilisateur ' . ($this->email ?? 'inconnu') . ': ' . $e->getMessage());
            throw $e;
        }
    }

    public function isVerificationCodeValid(string $code): bool
    {
        return $this->verification_token === $code
            && $this->verification_code_expires_at
            && now()->lte($this->verification_code_expires_at);
    }

    // ===============================
    // Scopes
    // ===============================

    public function scopeWithLegacyProjects($query)
    {
        return $query->with('legacyProjects');
    }

    public function scopeWithReports($query)
    {
        return $query->with('reports');
    }

    public function scopeWithAcceptedReports($query)
    {
        return $query->whereHas('reports', fn($q) => $q->where('status', 'accepted'));
    }

    public function scopeAcademicUsers($query)
    {
        return $query->whereHas('roles', fn($q) => $q->where('name', 'etudiant'));
    }

    public function scopeReportAdmins($query)
    {
        return $query->whereHas('roles', fn($q) => $q->where('name', 'admin'));
    }

    // ===============================
    // Boot
    // ===============================

    protected static function boot(): void
    {
        parent::boot();

        static::created(function ($user) {
            try {
                if (!$user->hasAnyRole(['admin', 'etudiant'])) {
                    $user->assignRole('etudiant');
                }
            } catch (Exception $e) {
                Log::error('Erreur lors de l\'assignation du rôle pour l\'utilisateur ' . ($user->email ?? 'inconnu') . ': ' . $e->getMessage());
            }
        });

        static::deleting(function ($user) {
            try {
                if ($user->cv_storage_path && Storage::disk('public')->exists($user->cv_storage_path)) {
                    Storage::disk('public')->delete($user->cv_storage_path);
                }
                if ($user->profile_image_url && Storage::disk('public')->exists($user->profile_image_url)) {
                    Storage::disk('public')->delete($user->profile_image_url);
                }
                $reports = $user->reports()->get();
                foreach ($reports as $report) {
                    if ($report->pdf_path && Storage::disk('public')->exists($report->pdf_path)) {
                        Storage::disk('public')->delete($report->pdf_path);
                    }
                }
            } catch (Exception $e) {
                Log::error('Erreur lors du nettoyage des fichiers pour l\'utilisateur ' . ($user->email ?? 'inconnu') . ': ' . $e->getMessage());
            }
        });
    }
    

    // ===============================
    // Applications helpers
    // ===============================

    public function hasAppliedToOffer(Offer $offer): bool
    {
        return $this->applications()->where('offer_id', $offer->id)->exists();
    }

    public function getApplicationsCountAttribute(): int
    {
        return $this->applications()->count();
    }
}
