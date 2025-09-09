# Forcer l'encodage UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Définir les en-têtes HTTP
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
}

# Générer un timestamp unique pour éviter les conflits d'email
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Variable pour stocker le session_token et le verification_code
$sessionToken = $null
$verificationCode = $null

# Fonction pour afficher les réponses
function Write-Response {
    param ($response, $step)
    Write-Host "Succes a l'etape $step !" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3)
}

# Fonction pour gérer les erreurs
function Handle-Error {
    param ($error, $step)
    Write-Host "Erreur a l'etape $step : $($error.Exception.Message)" -ForegroundColor Red
    Write-Host $error.ErrorDetails.Message
    exit
}

# Étape 1 : Informations personnelles
Write-Host "Test de l'etape 1 : Informations personnelles" -ForegroundColor Yellow
$bodyStep1 = @{
    nom_complet = "Jean Test"
    email = "test$timestamp@example.com"
    password = "password123"
    telephone = "+33123456789"
    nationalite = "Francaise"
} | ConvertTo-Json -Compress

Write-Host "Body envoye :" -ForegroundColor Yellow
Write-Host $bodyStep1

$bodyBytesStep1 = [System.Text.Encoding]::UTF8.GetBytes($bodyStep1)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/register/v2/step1" -Method POST -Headers $headers -Body $bodyBytesStep1
    Write-Response -response $response -step 1
    $sessionToken = $response.session_token
    Write-Host "Session Token : $sessionToken" -ForegroundColor Cyan
}
catch {
    Handle-Error -error $_ -step 1
}

# Étape 2 : Éducation
Write-Host "`nTest de l'etape 2 : Education" -ForegroundColor Yellow
$bodyStep2 = @{
    session_token = $sessionToken
    ecole = "Universite de Paris"
    filiere = "Informatique"
    niveau_etude = "Master"
    ville = "Paris"
} | ConvertTo-Json -Compress

Write-Host "Body envoye :" -ForegroundColor Yellow
Write-Host $bodyStep2

$bodyBytesStep2 = [System.Text.Encoding]::UTF8.GetBytes($bodyStep2)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/register/v2/step2" -Method POST -Headers $headers -Body $bodyBytesStep2
    Write-Response -response $response -step 2
}
catch {
    Handle-Error -error $_ -step 2
}

# Étape 3 : Profil académique (optionnel)
Write-Host "`nTest de l'etape 3 : Profil academique" -ForegroundColor Yellow
$bodyStep3 = @{
    session_token = $sessionToken
    cv_url = "https://example.com/cv.pdf"
    competences = @("PHP", "Laravel", "JavaScript")
    projects = @(
        @{
            title = "Projet Test"
            description = "Description du projet test"
            link = "https://example.com/projet"
        }
    )
} | ConvertTo-Json -Compress

Write-Host "Body envoye :" -ForegroundColor Yellow
Write-Host $bodyStep3

$bodyBytesStep3 = [System.Text.Encoding]::UTF8.GetBytes($bodyStep3)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/register/v2/step3" -Method POST -Headers $headers -Body $bodyBytesStep3
    Write-Response -response $response -step 3
}
catch {
    Handle-Error -error $_ -step 3
}

# Étape 4 : AMCI + Envoi du code de vérification
Write-Host "`nTest de l'etape 4 : AMCI + Envoi code" -ForegroundColor Yellow
$bodyStep4 = @{
    session_token = $sessionToken
    code_amci = "AMCI123456"
    affilie_amci = $true
} | ConvertTo-Json -Compress

Write-Host "Body envoye :" -ForegroundColor Yellow
Write-Host $bodyStep4

$bodyBytesStep4 = [System.Text.Encoding]::UTF8.GetBytes($bodyStep4)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/register/v2/step4" -Method POST -Headers $headers -Body $bodyBytesStep4
    Write-Response -response $response -step 4
    $verificationCode = $response.verification_code
    Write-Host "Code de verification : $verificationCode" -ForegroundColor Cyan
}
catch {
    Handle-Error -error $_ -step 4
}

# Test utilitaire : Récupérer les données d'une étape (exemple : étape 1)
Write-Host "`nTest de getStepData (etape 1)" -ForegroundColor Yellow
try {
    $uri = "http://127.0.0.1:8080/api/register/v2/step-data/1?session_token=$sessionToken"
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
    Write-Response -response $response -step "getStepData"
}
catch {
    Write-Host "Erreur a getStepData (ignoree, car le processus peut etre termine) : $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test utilitaire : Obtenir l'état du processus
Write-Host "`nTest de getProcessStatus" -ForegroundColor Yellow
try {
    $uri = "http://127.0.0.1:8080/api/register/v2/status?session_token=$sessionToken"
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
    Write-Response -response $response -step "getProcessStatus"
}
catch {
    Write-Host "Erreur a getProcessStatus (ignoree, car le processus peut etre termine) : $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test utilitaire : Renvoyer le code de vérification
Write-Host "`nTest de resend-code" -ForegroundColor Yellow
$bodyResend = @{
    session_token = $sessionToken
} | ConvertTo-Json -Compress

Write-Host "Body envoye :" -ForegroundColor Yellow
Write-Host $bodyResend

$bodyBytesResend = [System.Text.Encoding]::UTF8.GetBytes($bodyResend)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/register/v2/resend-code" -Method POST -Headers $headers -Body $bodyBytesResend
    Write-Response -response $response -step "resend-code"
    $verificationCode = $response.verification_code  # Mettre à jour le code de vérification
    Write-Host "Nouveau code de verification : $verificationCode" -ForegroundColor Cyan
}
catch {
    Write-Host "Erreur a resend-code (ignoree, car le processus peut etre termine) : $($_.Exception.Message)" -ForegroundColor Yellow
}

# Étape 5 : Vérification du code + Finalisation
Write-Host "`nTest de l'etape 5 : Verification code" -ForegroundColor Yellow
$bodyStep5 = @{
    session_token = $sessionToken
    verification_code = $verificationCode
} | ConvertTo-Json -Compress

Write-Host "Body envoye :" -ForegroundColor Yellow
Write-Host $bodyStep5

$bodyBytesStep5 = [System.Text.Encoding]::UTF8.GetBytes($bodyStep5)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/register/v2/step5" -Method POST -Headers $headers -Body $bodyBytesStep5
    Write-Response -response $response -step 5
}
catch {
    Handle-Error -error $_ -step 5
}

# Test utilitaire : Abandonner l'inscription
Write-Host "`nTest de abandonRegistration" -ForegroundColor Yellow
$bodyAbandon = @{
    session_token = $sessionToken
} | ConvertTo-Json -Compress

Write-Host "Body envoye :" -ForegroundColor Yellow
Write-Host $bodyAbandon

$bodyBytesAbandon = [System.Text.Encoding]::UTF8.GetBytes($bodyAbandon)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/register/v2/abandon" -Method POST -Headers $headers -Body $bodyBytesAbandon
    Write-Response -response $response -step "abandonRegistration"
}
catch {
    Write-Host "Erreur a abandonRegistration (ignoree, car le processus peut etre termine) : $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`nTest complet termine !" -ForegroundColor Green