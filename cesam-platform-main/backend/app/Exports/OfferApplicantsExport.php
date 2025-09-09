<?php

namespace App\Exports;

use App\Models\Offer;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class OfferApplicantsExport implements FromCollection, WithHeadings, WithMapping
{
    public function collection()
    {
        // Récupérer toutes les candidatures avec relations
        return Offer::with(['applicants'])->get();
    }

    public function headings(): array
    {
        return [
            'Offre',
            'Type',
            'Etudiant',
            'Email',
            'Téléphone',
            'Compétences',
            'Projets'
        ];
    }

    public function map($offer): array
    {
        $rows = [];
        foreach ($offer->applicants as $user) {
            $rows[] = [
                $offer->title,
                $offer->type,
                $user->nom_complet,
                $user->email,
                $user->telephone,
                implode(', ', $user->competences),
                implode('; ', array_map(fn($p) => $p['title'] ?? '', $user->projects ?? []))
            ];
        }

        return empty($rows) ? [
            $offer->title,
            $offer->type,
            'Aucun',
            '',
            '',
            '',
            ''
        ] : $rows[0]; // Laravel Excel n’accepte qu’un array par map
    }
}
