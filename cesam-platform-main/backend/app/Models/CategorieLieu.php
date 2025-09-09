<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

// Modèle CategorieLieu
class CategorieLieu extends Model
{
    use HasFactory;

    protected $table = 'categories_lieux';

    protected $fillable = [
        'nom',
        'description',
        'icon',
    ];

    /**
     * Get all places in this category.
     */
    public function lieux()
    {
        return $this->hasMany(Lieu::class, 'categorie_id');
    }
}
