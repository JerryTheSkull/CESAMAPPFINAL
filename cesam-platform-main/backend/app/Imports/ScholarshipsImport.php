<?php

namespace App\Imports;

use App\Models\Scholarship;
use Maatwebsite\Excel\Concerns\ToCollection;
use Illuminate\Support\Collection;

class ScholarshipsImport implements ToCollection
{
    /**
     * Lire le fichier Excel ligne par ligne
     * @param Collection $rows
     */
    public function collection(Collection $rows)
    {
        $matriculesDuFichier = [];

        foreach ($rows as $index => $row) {
            if ($index === 0) continue; // Ignorer la première ligne si c'est le titre
            if (empty(array_filter($row->toArray()))) continue; // Ignorer les lignes vides

            // Les colonnes sont lues par ordre : pays, matricule, nom, passport, unknown_field, code
            $data = [
                'country'          => $row[0] ?? null,
                'amci_matricule'   => $row[1] ?? null,
                'name'             => $row[2] ?? null,
                'passport'         => $row[3] ?? null,
                'unknown_field'    => $row[4] ?? null,
                'scholarship_code' => $row[5] ?? null,
            ];

            if (!$data['amci_matricule']) continue; // ne pas insérer si matricule vide

            // Upsert : update si existe, insert sinon
            Scholarship::updateOrCreate(
                ['amci_matricule' => $data['amci_matricule']],
                $data
            );

            $matriculesDuFichier[] = $data['amci_matricule'];
        }

        // Supprimer les bourses qui ne sont plus dans le fichier Excel
        Scholarship::whereNotIn('amci_matricule', $matriculesDuFichier)->delete();
    }
}
