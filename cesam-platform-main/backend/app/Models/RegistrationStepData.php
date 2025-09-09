<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class RegistrationStepData extends Model
{
    use HasFactory;

    protected $table = 'registration_step_data';
    
    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'process_id',
        'step_number',
        'data'
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
    public function scopeForStep($query, int $stepNumber)
    {
        return $query->where('step_number', $stepNumber);
    }

    public function scopeForProcess($query, string $processId)
    {
        return $query->where('process_id', $processId);
    }

    // Méthodes utilitaires
    public function getValue(string $key, $default = null)
    {
        return data_get($this->data, $key, $default);
    }

    public function setValue(string $key, $value): self
    {
        $data = $this->data ?? [];
        data_set($data, $key, $value);
        $this->data = $data;
        
        return $this;
    }

    public function hasValue(string $key): bool
    {
        // Utilisation d'Arr::has au lieu de data_has
        return \Illuminate\Support\Arr::has($this->data ?? [], $key);
    }

    public function removeValue(string $key): self
    {
        $data = $this->data ?? [];
        // Utilisation d'Arr::forget au lieu de data_forget
        \Illuminate\Support\Arr::forget($data, $key);
        $this->data = $data;
        
        return $this;
    }
}