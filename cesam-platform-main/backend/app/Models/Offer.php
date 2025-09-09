<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Offer extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'type',
        'description',
        'images',
        'links',
        'pdfs',
        'published_at',
        'is_active',
    ];

    protected $casts = [
        'images' => 'json',
        'links' => 'json',
        'pdfs' => 'json',
        'published_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    /**
     * Boot du modèle pour définir la date de publication automatiquement
     */
    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($offer) {
            if (empty($offer->published_at)) {
                $offer->published_at = now();
            }
        });

        static::deleting(function ($offer) {
            // Supprimer les fichiers associés
            if ($offer->images) {
                foreach ($offer->images as $image) {
                    if (Storage::disk('public')->exists($image)) {
                        Storage::disk('public')->delete($image);
                    }
                }
            }

            if ($offer->pdfs) {
                foreach ($offer->pdfs as $pdf) {
                    if (Storage::disk('public')->exists($pdf)) {
                        Storage::disk('public')->delete($pdf);
                    }
                }
            }
        });
    }

    /**
     * Relation avec les candidatures
     */
    public function applications()
    {
        return $this->hasMany(Application::class);
    }

    /**
     * Relation avec les utilisateurs qui ont postulé
     */
    public function applicants()
    {
        return $this->belongsToMany(User::class, 'applications')->withTimestamps();
    }

    /**
     * Vérifier si un utilisateur a déjà postulé à cette offre
     */
    public function hasApplied(User $user): bool
    {
        return $this->applications()->where('user_id', $user->id)->exists();
    }

    /**
     * Obtenir le nombre de candidatures
     */
    public function getApplicationsCountAttribute(): int
    {
        return $this->applications()->count();
    }

    /**
     * Scope pour les offres actives
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope pour les stages
     */
    public function scopeStages($query)
    {
        return $query->where('type', 'stage');
    }

    /**
     * Scope pour les emplois
     */
    public function scopeEmplois($query)
    {
        return $query->where('type', 'emploi');
    }

    /**
     * Obtenir les URLs publiques des images
     */
    public function getImageUrlsAttribute(): array
    {
        if (!$this->images) {
            return [];
        }

        return array_map(function ($image) {
            return asset('storage/' . $image);
        }, $this->images);
    }

    /**
     * Obtenir les URLs publiques des PDFs
     */
    public function getPdfUrlsAttribute(): array
    {
        if (!$this->pdfs) {
            return [];
        }

        return array_map(function ($pdf) {
            return asset('storage/' . $pdf);
        }, $this->pdfs);
    }
}