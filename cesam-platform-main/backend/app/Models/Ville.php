<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

// Modèle Ville
class Ville extends Model
{
    use HasFactory;

    protected $fillable = [
        'nom',
        'region',
    ];

    /**
     * Get all places in this city.
     */
    public function lieux()
    {
        return $this->hasMany(Lieu::class);
    }
}