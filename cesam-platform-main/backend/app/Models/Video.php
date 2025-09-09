<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Video extends Model
{
    use HasFactory;

    protected $fillable = [
        'titre',
        'description',
        'url',
        'miniature',
        'theme',
        'is_live',
        'is_active',
        'duree',
        'vues',
        'likes',
        'date_publication',
        'auteur_id',
    ];

    protected $casts = [
        'is_live' => 'boolean',
        'is_active' => 'boolean',
        'date_publication' => 'datetime',
        'vues' => 'integer',
        'likes' => 'integer',
        'duree' => 'integer',
    ];

    public function auteur()
    {
        return $this->belongsTo(User::class, 'auteur_id');
    }

    // Nouvelle relation avec les likes
    public function videoLikes()
    {
        return $this->hasMany(Like::class);
    }

    // Vérifier si un utilisateur a liké cette vidéo
    public function isLikedByUser($userId)
    {
        return $this->videoLikes()->where('user_id', $userId)->exists();
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeLive($query)
    {
        return $query->where('is_live', true);
    }

    public function scopeByTheme($query, $theme)
    {
        return $query->where('theme', $theme);
    }

    public function incrementViews()
    {
        $this->increment('vues');
    }

    public function incrementLikes()
    {
        $this->increment('likes');
    }

    public function decrementLikes()
    {
        $this->decrement('likes');
    }
}