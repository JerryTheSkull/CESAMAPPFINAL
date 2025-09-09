<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Scholarship extends Model
{
    use HasFactory;

    protected $fillable = [
        'country',
        'amci_matricule',
        'name',
        'passport',
        'unknown_field',
        'scholarship_code',
    ];
}