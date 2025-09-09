<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class RegistrationAuditLog extends Model
{
    use HasFactory;

    protected $table = 'registration_audit_logs';
    
    protected $keyType = 'string';
    public $incrementing = false;

    public $timestamps = true;

    protected $fillable = [
        'process_id',
        'action',
        'step_number',
        'data',
        'ip_address',
        'user_agent'
    ];

    protected $casts = [
        'data' => 'array',
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
    public function process()
    {
        return $this->belongsTo(RegistrationProcess::class, 'process_id');
    }

    // Scopes
    public function scopeForProcess($query, string $processId)
    {
        return $query->where('process_id', $processId);
    }

    public function scopeForAction($query, string $action)
    {
        return $query->where('action', $action);
    }

    public function scopeForStep($query, int $stepNumber)
    {
        return $query->where('step_number', $stepNumber);
    }

    public function scopeRecent($query, int $days = 30)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    // Méthodes statiques pour création rapide
    public static function logAction(string $processId, string $action, ?int $stepNumber = null, ?array $data = null): self
    {
        return self::create([
            'process_id' => $processId,
            'action' => $action,
            'step_number' => $stepNumber,
            'data' => $data,
            'ip_address' => request()?->ip(),
            'user_agent' => request()?->userAgent()
        ]);
    }

    public static function logStepCompleted(string $processId, int $stepNumber, array $data = []): self
    {
        return self::logAction($processId, 'step_completed', $stepNumber, $data);
    }

    public static function logStepUpdated(string $processId, int $stepNumber, array $data = []): self
    {
        return self::logAction($processId, 'step_updated', $stepNumber, $data);
    }

    public static function logCodeSent(string $processId, int $stepNumber = 4): self
    {
        return self::logAction($processId, 'code_sent', $stepNumber);
    }

    public static function logCodeVerified(string $processId, int $stepNumber = 5): self
    {
        return self::logAction($processId, 'code_verified', $stepNumber);
    }

    public static function logAbandoned(string $processId, int $currentStep): self
    {
        return self::logAction($processId, 'abandoned', $currentStep);
    }

    public static function logCompleted(string $processId): self
    {
        return self::logAction($processId, 'completed', 5);
    }

    // Méthodes utilitaires
    public function getFormattedAction(): string
    {
        $actions = [
            'step_completed' => 'Étape complétée',
            'step_updated' => 'Étape mise à jour',
            'code_sent' => 'Code envoyé',
            'code_verified' => 'Code vérifié',
            'abandoned' => 'Inscription abandonnée',
            'completed' => 'Inscription complétée',
            'expired' => 'Session expirée'
        ];

        return $actions[$this->action] ?? ucfirst($this->action);
    }

    public function getContextInfo(): string
    {
        $info = [];
        
        if ($this->step_number) {
            $info[] = "Étape {$this->step_number}";
        }
        
        if ($this->ip_address) {
            $info[] = "IP: {$this->ip_address}";
        }
        
        return implode(' | ', $info);
    }
}