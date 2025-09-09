<?php

namespace App\Exports;

use App\Models\Scholarship;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;

class ScholarshipsExport implements FromCollection, WithHeadings
{
    /**
     * @return \Illuminate\Support\Collection
     */
    public function collection()
    {
        return Scholarship::all();
    }

    /**
     * @return array
     */
    public function headings(): array
    {
        return [
            'ID',
            'Pays',
            'Matricule AMCI',
            'Nom',
            'Passeport',
            'Champ Inconnu',
            'Code de Bourse',
            'Créé le',
            'Mis à jour le',
        ];
    }
}