# Forcer l'encodage UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Définir les en-têtes HTTP de base
$headers = @{
    "Content-Type" = "application/json; charset=utf-8"
    "Accept" = "application/json"
}

# Variable pour stocker le token d'authentification
$authToken = $null

# Fonction pour afficher les réponses
function Write-Response {
    param ($response, $step)
    Write-Host "Succès à l'étape $step !" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3)
    Write-Host ("-" * 50) -ForegroundColor Gray
}

# Fonction pour gérer les erreurs
function Handle-Error {
    param ($error, $step)
    Write-Host "Erreur à l'étape $step : $($error.Exception.Message)" -ForegroundColor Red
    if ($error.ErrorDetails) {
        Write-Host $error.ErrorDetails.Message
    }
    Write-Host ("-" * 50) -ForegroundColor Gray
}

Write-Host "TEST API PROJECTS - CESAM PLATFORM" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Étape 1 : Connexion pour obtenir un token Sanctum
Write-Host "`n1. Test de la connexion (login)" -ForegroundColor Yellow
$bodyLogin = @{
    email = "ravaosolomarguerite66@gmail.com"  # Remplacez par votre email
    password = "123456"                        # Remplacez par votre mot de passe
} | ConvertTo-Json -Compress

Write-Host "Body envoyé :" -ForegroundColor Yellow
Write-Host $bodyLogin

$bodyBytesLogin = [System.Text.Encoding]::UTF8.GetBytes($bodyLogin)
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/login" -Method POST -Headers $headers -Body $bodyBytesLogin
    Write-Response -response $response -step "login"
    
    # Adapter selon votre structure de réponse (data.access_token ou directement access_token)
    if ($response.data -and $response.data.access_token) {
        $authToken = $response.data.access_token
    } elseif ($response.access_token) {
        $authToken = $response.access_token
    } else {
        Write-Host "Token non trouvé dans la réponse" -ForegroundColor Red
        exit
    }
    
    Write-Host "Token d'authentification : $authToken" -ForegroundColor Cyan
}
catch {
    Handle-Error -error $_ -step "login"
    exit
}

# Ajouter le token aux en-têtes pour les requêtes suivantes
$headers["Authorization"] = "Bearer $authToken"

# Étape 2 : Lister tous les projets
Write-Host "`n2. Test de lister tous les projets (GET /api/projects-api)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/projects-api" -Method GET -Headers $headers
    Write-Response -response $response -step "getAllProjects"
}
catch {
    Handle-Error -error $_ -step "getAllProjects"
}

# Étape 3 : Obtenir les statistiques des projets
Write-Host "`n3. Test des statistiques (GET /api/projects-api/stats)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/projects-api/stats" -Method GET -Headers $headers
    Write-Response -response $response -step "getStats"
}
catch {
    Handle-Error -error $_ -step "getStats"
}

# Étape 4 : Obtenir les projets d'un utilisateur spécifique
Write-Host "`n4. Test des projets d'un utilisateur (GET /api/projects-api/user/85)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/projects-api/user/85" -Method GET -Headers $headers
    Write-Response -response $response -step "getUserProjects"
}
catch {
    Handle-Error -error $_ -step "getUserProjects"
}

# Étape 5 : Créer un nouveau projet
Write-Host "`n5. Test de création d'un projet (POST /api/projects-api)" -ForegroundColor Yellow
$bodyCreateProject = @{
    user_id = 85
    title = "Test Projet PowerShell"
    description = "Projet créé via script PowerShell pour tester l'API"
    link = "https://github.com/test/projet"
} | ConvertTo-Json -Compress

Write-Host "Body envoyé :" -ForegroundColor Yellow
Write-Host $bodyCreateProject

$bodyBytesCreate = [System.Text.Encoding]::UTF8.GetBytes($bodyCreateProject)
$createdProjectId = $null
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/projects-api" -Method POST -Headers $headers -Body $bodyBytesCreate
    Write-Response -response $response -step "createProject"
    
    if ($response.data -and $response.data.id) {
        $createdProjectId = $response.data.id
        Write-Host "ID du projet créé : $createdProjectId" -ForegroundColor Cyan
    }
}
catch {
    Handle-Error -error $_ -step "createProject"
}

# Étape 6 : Voir le projet créé (si création réussie)
if ($createdProjectId) {
    Write-Host "`n6. Test de récupération d'un projet (GET /api/projects-api/$createdProjectId)" -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/projects-api/$createdProjectId" -Method GET -Headers $headers
        Write-Response -response $response -step "getProject"
    }
    catch {
        Handle-Error -error $_ -step "getProject"
    }

    # Étape 7 : Modifier le projet
    Write-Host "`n7. Test de modification du projet (PUT /api/projects-api/$createdProjectId)" -ForegroundColor Yellow
    $bodyUpdateProject = @{
        title = "Test Projet PowerShell - MODIFIE"
        description = "Description mise à jour via PowerShell"
        link = "https://github.com/test/projet-modifie"
    } | ConvertTo-Json -Compress

    Write-Host "Body envoyé :" -ForegroundColor Yellow
    Write-Host $bodyUpdateProject

    $bodyBytesUpdate = [System.Text.Encoding]::UTF8.GetBytes($bodyUpdateProject)
    try {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/projects-api/$createdProjectId" -Method PUT -Headers $headers -Body $bodyBytesUpdate
        Write-Response -response $response -step "updateProject"
    }
    catch {
        Handle-Error -error $_ -step "updateProject"
    }

    # Étape 8 : Supprimer le projet
    Write-Host "`n8. Test de suppression du projet (DELETE /api/projects-api/$createdProjectId)" -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/projects-api/$createdProjectId" -Method DELETE -Headers $headers
        Write-Response -response $response -step "deleteProject"
    }
    catch {
        Handle-Error -error $_ -step "deleteProject"
    }
} else {
    Write-Host "`nÉtapes 6, 7 et 8 ignorées car la création du projet a échoué" -ForegroundColor Yellow
}

# Étape 9 : Test avec filtres et pagination
Write-Host "`n9. Test avec filtres" -ForegroundColor Yellow
try {
    $uri = "http://127.0.0.1:8080/api/projects-api?user_id=85&sort_by=title&per_page=5"
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
    Write-Response -response $response -step "getProjectsWithFilters"
}
catch {
    Handle-Error -error $_ -step "getProjectsWithFilters"
}

Write-Host "`nTest complet terminé !" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green