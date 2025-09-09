<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class RegistrationProcess extends Model
{
    use HasFactory;

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'session_token',
        'user_email',
        'current_step',
        'total_steps',
        'status',
        'metadata',
        'expires_at'
    ];

    protected $casts = [
        'metadata' => 'array',
        'expires_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
        });
    }

    // Relations
    public function stepData()
    {
        return $this->hasMany(RegistrationStepData::class, 'process_id');
    }

    public function auditLogs()
    {
        return $this->hasMany(RegistrationAuditLog::class, 'process_id');
    }

    public function user()
    {
        return $this->hasOne(User::class, 'registration_process_id', 'id');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'in_progress')
                    ->where('expires_at', '>', now());
    }

    public function scopeExpired($query)
    {
        return $query->where('expires_at', '<=', now())
                    ->where('status', '!=', 'completed');
    }

    // Méthodes utilitaires
    public function isExpired(): bool
    {
        return $this->expires_at->isPast() && $this->status !== 'completed';
    }

    public function isActive(): bool
    {
        return $this->status === 'in_progress' && !$this->isExpired();
    }

    public function getProgressPercentage(): int
    {
        return (int) (($this->current_step / $this->total_steps) * 100);
    }
}