# Forcer l'encodage UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Définir les en-têtes HTTP de base
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
}

# Variable pour stocker le token d'authentification
$authToken = $null

# Fonction pour afficher les réponses
function Write-Response {
    param ($response, $step)
    Write-Host "Succès à l'étape $step !" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3)
}

# Fonction pour gérer les erreurs
function Handle-Error {
    param ($error, $step)
    Write-Host "Erreur à l'étape $step : $($error.Exception.Message)" -ForegroundColor Red
    Write-Host $error.ErrorDetails.Message
    exit
}

# Étape 1 : Connexion pour obtenir un token Sanctum
Write-Host "Test de la connexion (login)" -ForegroundColor Yellow
$bodyLogin = @{
    email = "rnotsimbinina@gmail.com"  # Remplace par un email d'admin valide
    password = "123456"     # Remplace par le mot de passe correct
} | ConvertTo-Json -Compress

Write-Host "Body envoyé :" -ForegroundColor Yellow
Write-Host $bodyLogin

$bodyBytesLogin = [System.Text.Encoding]::UTF8.GetBytes($bodyLogin)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/login" -Method POST -Headers $headers -Body $bodyBytesLogin
    Write-Response -response $response -step "login"
    $authToken = $response.access_token  # Mise à jour pour correspondre à ton LoginController
    Write-Host "Token d'authentification : $authToken" -ForegroundColor Cyan
}
catch {
    Handle-Error -error $_ -step "login"
}

# Ajouter le token aux en-têtes pour les requêtes suivantes
$headers["Authorization"] = "Bearer $authToken"

# Étape 2 : Lister les utilisateurs avec filtres
Write-Host "`nTest de lister les utilisateurs (GET /api/admin/users)" -ForegroundColor Yellow
try {
    $uri = "http://127.0.0.1:8080/api/admin/users?verified=true&role=etudiant"  # Exemple avec filtres
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
    Write-Response -response $response -step "getUsers"
}
catch {
    Handle-Error -error $_ -step "getUsers"
}

# Étape 3 : Obtenir les statistiques
Write-Host "`nTest des statistiques (GET /api/admin/stats)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/admin/stats" -Method GET -Headers $headers
    Write-Response -response $response -step "getStats"
}
catch {
    Handle-Error -error $_ -step "getStats"
}

# Étape 4 : Approuver un utilisateur
Write-Host "`nTest d'approbation d'un utilisateur (PATCH /api/admin/users/1/approval)" -ForegroundColor Yellow
$bodyApproval = @{
    action = "approve"
} | ConvertTo-Json -Compress

Write-Host "Body envoyé :" -ForegroundColor Yellow
Write-Host $bodyApproval

$bodyBytesApproval = [System.Text.Encoding]::UTF8.GetBytes($bodyApproval)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/admin/users/1/approval" -Method PATCH -Headers $headers -Body $bodyBytesApproval
    Write-Response -response $response -step "approveUser"
}
catch {
    Handle-Error -error $_ -step "approveUser"
}

# Étape 5 : Changer le rôle d'un utilisateur
Write-Host "`nTest de changement de rôle (PATCH /api/admin/users/1/role)" -ForegroundColor Yellow
$bodyRole = @{
    role = "admin"  # Changer en "student" pour tester l'inverse
} | ConvertTo-Json -Compress

Write-Host "Body envoyé :" -ForegroundColor Yellow
Write-Host $bodyRole

$bodyBytesRole = [System.Text.Encoding]::UTF8.GetBytes($bodyRole)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/admin/users/1/role" -Method PATCH -Headers $headers -Body $bodyBytesRole
    Write-Response -response $response -step "changeRole"
}
catch {
    Handle-Error -error $_ -step "changeRole"
}

# Étape 6 : Supprimer un utilisateur
Write-Host "`nTest de suppression d'un utilisateur (DELETE /api/admin/users/1)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/admin/users/1" -Method DELETE -Headers $headers
    Write-Response -response $response -step "deleteUser"
}
catch {
    Handle-Error -error $_ -step "deleteUser"
}

Write-Host "`nTest complet terminé !" -ForegroundColor Green