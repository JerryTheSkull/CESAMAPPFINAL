<?php

namespace App\Services;

use App\Models\Offer;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Font;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class ExcelExportService
{
    /**
     * Exporter les candidatures d'une offre vers Excel
     */
    public static function exportApplications(Offer $offer): string
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        // Configuration du titre
        $sheet->setTitle('Candidatures - ' . substr($offer->title, 0, 30));
        
        // En-tête du document
        $sheet->setCellValue('A1', 'CANDIDATURES POUR L\'OFFRE');
        $sheet->setCellValue('A2', $offer->title);
        $sheet->setCellValue('A3', 'Type: ' . ucfirst($offer->type));
        $sheet->setCellValue('A4', 'Date d\'export: ' . now()->format('d/m/Y H:i'));
        
        // Style de l'en-tête
        $sheet->mergeCells('A1:H1');
        $sheet->mergeCells('A2:H2');
        $sheet->mergeCells('A3:H3');
        $sheet->mergeCells('A4:H4');
        
        $headerStyle = [
            'font' => ['bold' => true, 'size' => 14],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            'fill' => [
                'fillType' => Fill::FILL_SOLID,
                'startColor' => ['rgb' => 'E3F2FD']
            ]
        ];
        
        $sheet->getStyle('A1:A4')->applyFromArray($headerStyle);

        // En-têtes des colonnes (ligne 6)
        $headers = [
            'A6' => 'Nom Complet',
            'B6' => 'Email',
            'C6' => 'Téléphone',
            'D6' => 'Nationalité',
            'E6' => 'École/Établissement',
            'F6' => 'Filière',
            'G6' => 'Niveau d\'Étude',
            'H6' => 'Ville',
            'I6' => 'Compétences',
            'J6' => 'Projets',
            'K6' => 'Date de Candidature',
            'L6' => 'A un CV'
        ];

        foreach ($headers as $cell => $value) {
            $sheet->setCellValue($cell, $value);
        }

        // Style des en-têtes de colonnes
        $columnHeaderStyle = [
            'font' => ['bold' => true],
            'fill' => [
                'fillType' => Fill::FILL_SOLID,
                'startColor' => ['rgb' => 'BBDEFB']
            ],
            'borders' => [
                'allBorders' => [
                    'borderStyle' => Border::BORDER_THIN,
                    'color' => ['rgb' => '000000']
                ]
            ]
        ];
        
        $sheet->getStyle('A6:L6')->applyFromArray($columnHeaderStyle);

        // Charger les candidatures avec les données utilisateur
        $applications = $offer->applications()->with('user')->get();
        
        $row = 7; // Commencer à la ligne 7
        
        foreach ($applications as $application) {
            $user = $application->user;
            
            // Formater les compétences
            $competences = is_array($user->competences) 
                ? implode(', ', $user->competences) 
                : (string) $user->competences;
            
            // Formater les projets JSON
            $projets = '';
            if (!empty($user->projects) && is_array($user->projects)) {
                $projetsList = [];
                foreach ($user->projects as $project) {
                    $projetsList[] = $project['title'] ?? 'Projet sans titre';
                }
                $projets = implode(', ', $projetsList);
            }
            
            // Remplir les données
            $sheet->setCellValue('A' . $row, $user->nom_complet);
            $sheet->setCellValue('B' . $row, $user->email);
            $sheet->setCellValue('C' . $row, $user->telephone);
            $sheet->setCellValue('D' . $row, $user->nationalite);
            $sheet->setCellValue('E' . $row, $user->ecole ?? $user->etablissement ?? 'N/A');
            $sheet->setCellValue('F' . $row, $user->filiere);
            $sheet->setCellValue('G' . $row, $user->niveau_etude);
            $sheet->setCellValue('H' . $row, $user->ville);
            $sheet->setCellValue('I' . $row, $competences);
            $sheet->setCellValue('J' . $row, $projets);
            $sheet->setCellValue('K' . $row, $application->applied_at->format('d/m/Y H:i'));
            $sheet->setCellValue('L' . $row, $user->hasCV() ? 'Oui' : 'Non');
            
            $row++;
        }

        // Style des données
        if ($row > 7) {
            $dataRange = 'A7:L' . ($row - 1);
            $dataStyle = [
                'borders' => [
                    'allBorders' => [
                        'borderStyle' => Border::BORDER_THIN,
                        'color' => ['rgb' => 'CCCCCC']
                    ]
                ]
            ];
            $sheet->getStyle($dataRange)->applyFromArray($dataStyle);
        }

        // Ajuster la largeur des colonnes
        foreach (range('A', 'L') as $col) {
            $sheet->getColumnDimension($col)->setAutoSize(true);
        }

        // Sauvegarder le fichier
        $fileName = 'candidatures_' . str_replace([' ', '/'], '_', $offer->title) . '_' . now()->format('Y-m-d_H-i') . '.xlsx';
        $filePath = storage_path('app/temp/' . $fileName);
        
        // Créer le dossier temp s'il n'existe pas
        if (!is_dir(storage_path('app/temp'))) {
            mkdir(storage_path('app/temp'), 0755, true);
        }

        $writer = new Xlsx($spreadsheet);
        $writer->save($filePath);
        
        return $filePath;
    }

    /**
     * Nettoyer les fichiers temporaires anciens
     */
    public static function cleanupTempFiles(): void
    {
        $tempDir = storage_path('app/temp');
        
        if (is_dir($tempDir)) {
            $files = glob($tempDir . '/*.xlsx');
            
            foreach ($files as $file) {
                if (filemtime($file) < strtotime('-1 hour')) {
                    unlink($file);
                }
            }
        }
    }
}