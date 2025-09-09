# Forcer l'encodage UTF-8 pour la console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Définir les en-têtes HTTP de base
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
    "Accept" = "application/json"
}

# Variable pour stocker le token d'authentification
$authToken = $null

# Base URL de l'API
$baseUrl = "http://10.25.136.145:8080/api"

# Fonction pour afficher les réponses
function Write-Response {
    param ($response, $step)
    Write-Host "Success at step $step!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 5)
}

# Fonction pour gérer les erreurs
function Handle-Error {
    param ($error, $step)
    Write-Host "Error at step $step : $($error.Exception.Message)" -ForegroundColor Red
    if ($error.ErrorDetails) {
        Write-Host $error.ErrorDetails.Message
    }
    Write-Host "Continuing with remaining tests..." -ForegroundColor Yellow
}

# Fonction pour créer un fichier PDF de test
function Create-TestPDF {
    param ($filePath)
    try {
        $pdfContent = @"
%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj

2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj

3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
>>
endobj

4 0 obj
<<
/Length 55
>>
stream
BT
/F1 12 Tf
72 720 Td
(Test PFE Report PDF) Tj
ET
endstream
endobj

xref
0 5
0000000000 65535 f 
0000000010 00000 n 
0000000079 00000 n 
0000000173 00000 n 
0000000301 00000 n 
trailer
<<
/Size 5
/Root 1 0 R
>>
startxref
395
%%EOF
"@
        [System.IO.File]::WriteAllText($filePath, $pdfContent, [System.Text.Encoding]::ASCII)
        Write-Host "Test PDF file created: $filePath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to create test PDF file: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Étape 1 : Connexion
Write-Host "Testing login (POST /login)" -ForegroundColor Yellow
$bodyLogin = @{
    email = "admin@cesam.com"
    password = "password"
} | ConvertTo-Json -Compress

$bodyBytesLogin = [System.Text.Encoding]::UTF8.GetBytes($bodyLogin)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Headers $headers -Body $bodyBytesLogin
    Write-Response -response $response -step "login"
    $authToken = $response.access_token
    Write-Host "Authentication token: $authToken" -ForegroundColor Cyan
}
catch {
    Handle-Error -error $_ -step "login"
}

$headers["Authorization"] = "Bearer $authToken"

# Étape 2 : GET /reports
Write-Host "`nTesting public reports retrieval (GET /reports)" -ForegroundColor Yellow
$publicHeaders = @{
    "Accept" = "application/json"
}
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/reports" -Method GET -Headers $publicHeaders
    Write-Response -response $response -step "getPublicReports"
}
catch {
    Handle-Error -error $_ -step "getPublicReports"
}

# Étape 3 : Filtrage par domaine
Write-Host "`nTesting domain filtering (GET /reports?domain=Informatique & Numérique)" -ForegroundColor Yellow
$encodedDomain = [System.Web.HttpUtility]::UrlEncode("Informatique & Numérique")
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/reports?domain=$encodedDomain" -Method GET -Headers $publicHeaders
    Write-Response -response $response -step "filterByDomain"
}
catch {
    Handle-Error -error $_ -step "filterByDomain"
}

# Étape 4 : Filtrage par année
Write-Host "`nTesting year filtering (GET /reports?defense_year=2024)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/reports?defense_year=2024" -Method GET -Headers $publicHeaders
    Write-Response -response $response -step "filterByYear"
}
catch {
    Handle-Error -error $_ -step "filterByYear"
}

# Étape 5 : Soumission PFE
Write-Host "`nTesting PFE report submission (POST /reports)" -ForegroundColor Yellow
if ($authToken) {
    try {
        $tempDir = [System.IO.Path]::GetTempPath()
        $pdfFilePath = Join-Path $tempDir "test_pfe_report.pdf"
        if (-not (Test-Path $pdfFilePath)) { Create-TestPDF -filePath $pdfFilePath }

        $form = @{
            type        = "PFE"
            title       = "Développement d'une application mobile de gestion des étudiants"
            author_name = "Test Author PowerShell"
            defense_year= "2024"
            domain      = "Informatique & Numérique"
            pdf_file    = Get-Item -Path $pdfFilePath
        }

        $tempHeaders = $headers.Clone()
        $tempHeaders.Remove("Content-Type")

        $response = Invoke-RestMethod -Uri "$baseUrl/reports" -Method POST -Headers $tempHeaders -FormData $form
        Write-Response -response $response -step "submitPFE"
    }
    catch {
        Handle-Error -error $_ -step "submitPFE"
    }
}

# Étape 6 : Soumission PFA invalide
Write-Host "`nTesting PFA report submission with invalid domain (POST /reports)" -ForegroundColor Yellow
if ($authToken) {
    try {
        $tempDir = [System.IO.Path]::GetTempPath()
        $pdfFilePath = Join-Path $tempDir "test_pfa_report.pdf"
        if (-not (Test-Path $pdfFilePath)) { Create-TestPDF -filePath $pdfFilePath }

        $form = @{
            type        = "PFA"
            title       = "Projet de fin d'année - Système de gestion"
            author_name = "Test Author PFA"
            defense_year= "2023"
            domain      = "Domaine Inexistant"
            pdf_file    = Get-Item -Path $pdfFilePath
        }

        $tempHeaders = $headers.Clone()
        $tempHeaders.Remove("Content-Type")

        $response = Invoke-RestMethod -Uri "$baseUrl/reports" -Method POST -Headers $tempHeaders -FormData $form
        Write-Host "Warning: Invalid domain was accepted" -ForegroundColor Yellow
        Write-Response -response $response -step "submitPFA_InvalidDomain"
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 422) {
            Write-Host "Success: Invalid domain correctly rejected with 422 status" -ForegroundColor Green
        } else {
            Handle-Error -error $_ -step "submitPFA_InvalidDomain"
        }
    }
}

# Étape 9 : Validation année invalide
Write-Host "`nTesting validation with invalid year (POST /reports)" -ForegroundColor Yellow
if ($authToken) {
    try {
        $tempDir = [System.IO.Path]::GetTempPath()
        $pdfFilePath = Join-Path $tempDir "test_invalid_year.pdf"
        if (-not (Test-Path $pdfFilePath)) { Create-TestPDF -filePath $pdfFilePath }

        $form = @{
            type        = "PFE"
            title       = "Test avec année invalide"
            author_name = "Test Author"
            defense_year= "1999"
            domain      = "Informatique & Numérique"
            pdf_file    = Get-Item -Path $pdfFilePath
        }

        $tempHeaders = $headers.Clone()
        $tempHeaders.Remove("Content-Type")

        $response = Invoke-RestMethod -Uri "$baseUrl/reports" -Method POST -Headers $tempHeaders -FormData $form
        Write-Host "Warning: Invalid year was accepted" -ForegroundColor Yellow
        Write-Response -response $response -step "invalidYear"
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 422) {
            Write-Host "Success: Invalid year correctly rejected with 422 status" -ForegroundColor Green
        } else {
            Handle-Error -error $_ -step "invalidYear"
        }
    }
}

# Étape 11 : Déconnexion
Write-Host "`nTesting logout (POST /logout)" -ForegroundColor Yellow
if ($authToken) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/logout" -Method POST -Headers $headers
        Write-Response -response $response -step "logout"
    }
    catch {
        Handle-Error -error $_ -step "logout"
    }
}
