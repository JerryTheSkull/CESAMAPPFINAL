<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Application extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'offer_id',
        'applied_at',
    ];

    protected $casts = [
        'applied_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Boot du modèle pour définir la date de candidature automatiquement
     */
    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($application) {
            if (empty($application->applied_at)) {
                $application->applied_at = now();
            }
        });
    }

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relation avec l'offre
     */
    public function offer()
    {
        return $this->belongsTo(Offer::class);
    }
}