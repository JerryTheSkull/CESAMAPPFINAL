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
$baseUrl = "http://192.168.154.145:8080/api"

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
    Write-Host $error.ErrorDetails.Message
    # Continue instead of exiting to allow further tests
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
/Length 44
>>
stream
BT
/F1 12 Tf
72 720 Td
(Test CV PDF) Tj
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
379
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

# Fonction pour créer un fichier JPG de test
function Create-TestJPG {
    param ($filePath)
    try {
        Add-Type -AssemblyName System.Drawing
        $image = New-Object System.Drawing.Bitmap(100, 100)
        $graphics = [System.Drawing.Graphics]::FromImage($image)
        $graphics.Clear([System.Drawing.Color]::White)
        $font = New-Object System.Drawing.Font("Arial", 12)
        $brush = [System.Drawing.Brushes]::Black
        $graphics.DrawString("Test", $font, $brush, 10, 40)
        $image.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $graphics.Dispose()
        $image.Dispose()
        Write-Host "Test JPG file created: $filePath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to create test JPG file: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Étape 1 : Connexion pour obtenir un token Sanctum
Write-Host "Testing login (POST /login)" -ForegroundColor Yellow
$bodyLogin = @{
    email = "ravaosolomarguerite66@gmail.com"
    password = "password"
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodyLogin

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

# Ajouter le token aux en-têtes pour les requêtes suivantes
$headers["Authorization"] = "Bearer $authToken"

# Étape 2 : Récupérer le profil complet
Write-Host "`nTesting profile retrieval (GET /profile)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile" -Method GET -Headers $headers
    Write-Response -response $response -step "getProfile"
}
catch {
    Handle-Error -error $_ -step "getProfile"
}

# Étape 3 : Mettre à jour les informations personnelles
Write-Host "`nTesting personal info update (PUT /profile/personal)" -ForegroundColor Yellow
$bodyPersonalInfo = @{
    telephone = "+1234567890"
    ville = "TestCity"
    affilie_amci = $true
    code_amci = "TEST123"
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodyPersonalInfo

$bodyBytesPersonalInfo = [System.Text.Encoding]::UTF8.GetBytes($bodyPersonalInfo)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/personal" -Method PUT -Headers $headers -Body $bodyBytesPersonalInfo
    Write-Response -response $response -step "updatePersonalInfo"
}
catch {
    Handle-Error -error $_ -step "updatePersonalInfo"
}

# Étape 4 : Mettre à jour les informations académiques
Write-Host "`nTesting academic info update (PUT /profile/academic)" -ForegroundColor Yellow
$bodyAcademicInfo = @{
    ecole = "Test University"
    filiere = "Computer Science"
    niveau_etude = "Master 1"
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodyAcademicInfo

$bodyBytesAcademicInfo = [System.Text.Encoding]::UTF8.GetBytes($bodyAcademicInfo)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/academic" -Method PUT -Headers $headers -Body $bodyBytesAcademicInfo
    Write-Response -response $response -step "updateAcademicInfo"
}
catch {
    Handle-Error -error $_ -step "updateAcademicInfo"
}

# Étape 5 : Ajouter une compétence
Write-Host "`nTesting skill addition (POST /profile/skills)" -ForegroundColor Yellow
$bodySkill = @{
    skill = "Python"
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodySkill

$bodyBytesSkill = [System.Text.Encoding]::UTF8.GetBytes($bodySkill)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/skills" -Method POST -Headers $headers -Body $bodyBytesSkill
    Write-Response -response $response -step "addSkill"
}
catch {
    Handle-Error -error $_ -step "addSkill"
}

# Étape 6 : Mettre à jour toutes les compétences
Write-Host "`nTesting skills update (PUT /profile/skills)" -ForegroundColor Yellow
$bodySkills = @{
    skills = @("Java", "SQL", "Flutter")
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodySkills

$bodyBytesSkills = [System.Text.Encoding]::UTF8.GetBytes($bodySkills)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/skills" -Method PUT -Headers $headers -Body $bodyBytesSkills
    Write-Response -response $response -step "updateSkills"
}
catch {
    Handle-Error -error $_ -step "updateSkills"
}

# Étape 7 : Supprimer une compétence
Write-Host "`nTesting skill removal (DELETE /profile/skills)" -ForegroundColor Yellow
$bodyRemoveSkill = @{
    skill = "Java" # Changed from "Python" to "Java" to match updated skills
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodyRemoveSkill

$bodyBytesRemoveSkill = [System.Text.Encoding]::UTF8.GetBytes($bodyRemoveSkill)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/skills" -Method DELETE -Headers $headers -Body $bodyBytesRemoveSkill
    Write-Response -response $response -step "removeSkill"
}
catch {
    Handle-Error -error $_ -step "removeSkill"
}

# Étape 8 : Ajouter un projet
Write-Host "`nTesting project addition (POST /profile/projects)" -ForegroundColor Yellow
$bodyProject = @{
    title = "Test Project"
    description = "This is a test project description."
    link = "https://example.com"
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodyProject

$bodyBytesProject = [System.Text.Encoding]::UTF8.GetBytes($bodyProject)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/projects" -Method POST -Headers $headers -Body $bodyBytesProject
    Write-Response -response $response -step "addProject"
    $projectId = $response.data.id
}
catch {
    Handle-Error -error $_ -step "addProject"
}

# Étape 9 : Mettre à jour un projet
Write-Host "`nTesting project update (PUT /profile/projects/$projectId)" -ForegroundColor Yellow
$bodyUpdateProject = @{
    title = "Updated Test Project"
    description = "Updated project description."
    link = "https://updated-example.com"
} | ConvertTo-Json -Compress

Write-Host "Body sent:" -ForegroundColor Yellow
Write-Host $bodyUpdateProject

$bodyBytesUpdateProject = [System.Text.Encoding]::UTF8.GetBytes($bodyUpdateProject)
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/projects/$projectId" -Method PUT -Headers $headers -Body $bodyBytesUpdateProject
    Write-Response -response $response -step "updateProject"
}
catch {
    Handle-Error -error $_ -step "updateProject"
}

# Étape 10 : Supprimer un projet
Write-Host "`nTesting project deletion (DELETE /profile/projects/$projectId)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/projects/$projectId" -Method DELETE -Headers $headers
    Write-Response -response $response -step "deleteProject"
}
catch {
    Handle-Error -error $_ -step "deleteProject"
}

# Étape 11 : Téléverser une photo de profil
Write-Host "`nTesting profile photo upload (POST /profile/photo)" -ForegroundColor Yellow
try {
    $tempDir = [System.IO.Path]::GetTempPath()
    $photoFilePath = Join-Path $tempDir "test_photo.jpg"
    
    if (-not (Test-Path $photoFilePath)) {
        $photoCreated = Create-TestJPG -filePath $photoFilePath
        if (-not $photoCreated) {
            throw "Failed to create test JPG file"
        }
    }
    
    Write-Host "Using file: $photoFilePath" -ForegroundColor Cyan
    
    $form = @{
        photo = Get-Item -Path $photoFilePath
    }
    
    $tempHeaders = $headers.Clone()
    $tempHeaders.Remove("Content-Type")
    
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/photo" -Method POST -Headers $tempHeaders -Form $form
    Write-Response -response $response -step "uploadPhoto"
    
    Remove-Item $photoFilePath -Force -ErrorAction SilentlyContinue
}
catch {
    Handle-Error -error $_ -step "uploadPhoto"
}
finally {
    $headers["Content-Type"] = "application/json; charset=utf-8"
}

# Étape 12 : Supprimer la photo de profil
Write-Host "`nTesting profile photo deletion (DELETE /profile/photo)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/photo" -Method DELETE -Headers $headers
    Write-Response -response $response -step "deletePhoto"
}
catch {
    Handle-Error -error $_ -step "deletePhoto"
}

# Étape 13 : Téléverser un CV
Write-Host "`nTesting CV upload (POST /profile/cv)" -ForegroundColor Yellow
try {
    $tempDir = [System.IO.Path]::GetTempPath()
    $cvFilePath = Join-Path $tempDir "test_cv.pdf"
    
    if (-not (Test-Path $cvFilePath)) {
        $pdfCreated = Create-TestPDF -filePath $cvFilePath
        if (-not $pdfCreated) {
            throw "Failed to create test PDF file"
        }
    }
    
    Write-Host "Using file: $cvFilePath" -ForegroundColor Cyan
    
    $form = @{
        cv = Get-Item -Path $cvFilePath
    }
    
    $tempHeaders = $headers.Clone()
    $tempHeaders.Remove("Content-Type")
    
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/cv" -Method POST -Headers $tempHeaders -Form $form
    Write-Response -response $response -step "uploadCV"
    
    Remove-Item $cvFilePath -Force -ErrorAction SilentlyContinue
}
catch {
    Handle-Error -error $_ -step "uploadCV"
}
finally {
    $headers["Content-Type"] = "application/json; charset=utf-8"
}

# Étape 14 : Supprimer le CV
Write-Host "`nTesting CV deletion (DELETE /profile/cv)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/profile/cv" -Method DELETE -Headers $headers
    Write-Response -response $response -step "deleteCV"
}
catch {
    Handle-Error -error $_ -step "deleteCV"
}

# Étape 15 : Déconnexion
Write-Host "`nTesting logout (POST /logout)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/logout" -Method POST -Headers $headers
    Write-Response -response $response -step "logout"
}
catch {
    Handle-Error -error $_ -step "logout"
}

Write-Host "`nAll tests completed!" -ForegroundColor Green
