<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;

class Report extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'author_name',
        'title',
        'type',
        'defense_year',
        'domain',
        'description',
        'keywords',
        'pdf_path',
        'status',
        'admin_id',
        'admin_comment',
        'submitted_at',
        'processed_at',
    ];

    protected $casts = [
        'defense_year' => 'integer',
        'submitted_at' => 'datetime',
        'processed_at' => 'datetime',
    ];

    // Relations
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function admin()
    {
        return $this->belongsTo(User::class, 'admin_id');
    }

    // Accesseur pour URL du PDF - VERSION CORRIGÉE
    public function getPdfUrlAttribute()
    {
        if (!$this->pdf_path) {
            return null;
        }
        
        // ✅ URL complète avec le domaine pour accès externe
        return config('app.url') . Storage::url($this->pdf_path);
    }

    // Scopes utiles
    public function scopeAccepted($query)
    {
        return $query->where('status', 'accepted');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }
}