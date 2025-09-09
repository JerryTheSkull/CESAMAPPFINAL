# Script de debug pour l'authentification
$baseUrl = "http://127.0.0.1:8080/api"

Write-Host "ÉTAPE 1 : Connexion et récupération du token" -ForegroundColor Yellow

# Connexion
$loginBody = @{
    email = "admin@cesam.com"
    password = "password"
} | ConvertTo-Json

$loginHeaders = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Headers $loginHeaders -Body $loginBody
    Write-Host "Token reçu : $($loginResponse.access_token)" -ForegroundColor Green
    $token = $loginResponse.access_token
} catch {
    Write-Host "Erreur de connexion : $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "`nÉTAPE 2 : Test du token avec différentes méthodes" -ForegroundColor Yellow

# Méthode 1 : Headers standard
Write-Host "2.1 - Test avec headers standard" -ForegroundColor Cyan
$headers1 = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/json"
    "Content-Type" = "application/json"
}

try {
    $response1 = Invoke-RestMethod -Uri "$baseUrl/user/reports/my-reports" -Method GET -Headers $headers1
    Write-Host "SUCCÈS avec headers standard !" -ForegroundColor Green
    Write-Host ($response1 | ConvertTo-Json -Depth 2)
} catch {
    Write-Host "ÉCHEC avec headers standard : $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow
    }
}

Write-Host "`n2.2 - Test avec Invoke-WebRequest au lieu d'Invoke-RestMethod" -ForegroundColor Cyan
try {
    $response2 = Invoke-WebRequest -Uri "$baseUrl/user/reports/my-reports" -Method GET -Headers $headers1
    Write-Host "SUCCÈS avec Invoke-WebRequest !" -ForegroundColor Green
    Write-Host "Status: $($response2.StatusCode)" -ForegroundColor Green
    Write-Host ($response2.Content | ConvertFrom-Json | ConvertTo-Json -Depth 2)
} catch {
    Write-Host "ÉCHEC avec Invoke-WebRequest : $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow
    }
}

Write-Host "`n2.3 - Vérification du token en lui-même" -ForegroundColor Cyan
Write-Host "Token complet : $token" -ForegroundColor White
Write-Host "Longueur du token : $($token.Length)" -ForegroundColor White
Write-Host "Premiers caractères : $($token.Substring(0, [Math]::Min(20, $token.Length)))" -ForegroundColor White

Write-Host "`n2.4 - Test avec headers explicites" -ForegroundColor Cyan
$headers2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers2.Add("Authorization", "Bearer $token")
$headers2.Add("Accept", "application/json")
$headers2.Add("Content-Type", "application/json")

try {
    $response3 = Invoke-RestMethod -Uri "$baseUrl/user/reports/my-reports" -Method GET -Headers $headers2
    Write-Host "SUCCÈS avec Dictionary headers !" -ForegroundColor Green
    Write-Host ($response3 | ConvertTo-Json -Depth 2)
} catch {
    Write-Host "ÉCHEC avec Dictionary headers : $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow
    }
}

Write-Host "`nÉTAPE 3 : Vérification de la validité du token côté serveur" -ForegroundColor Yellow

# Test avec une route qui nous donne des infos sur l'utilisateur connecté
Write-Host "3.1 - Test route /user (si elle existe)" -ForegroundColor Cyan
try {
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/user" -Method GET -Headers $headers1
    Write-Host "SUCCÈS - Informations utilisateur :" -ForegroundColor Green
    Write-Host ($userResponse | ConvertTo-Json -Depth 2)
} catch {
    Write-Host "Route /user n'existe pas ou échec : $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

Write-Host "`nÉTAPE 4 : Debug des headers envoyés" -ForegroundColor Yellow
Write-Host "Headers actuels :" -ForegroundColor Cyan
$headers1.GetEnumerator() | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)" -ForegroundColor White
}

Write-Host "`nÉTAPE 5 : Recommandations de debug" -ForegroundColor Yellow
Write-Host "Pour débugger côté Laravel :" -ForegroundColor Cyan
Write-Host "1. Ajoutez dans votre contrôleur :" -ForegroundColor White
Write-Host "   \Log::info('Auth check:', ['user' => auth()->user(), 'token' => request()->bearerToken()]);" -ForegroundColor Gray
Write-Host "2. Vérifiez les logs :" -ForegroundColor White
Write-Host "   tail -f storage/logs/laravel.log" -ForegroundColor Gray
Write-Host "3. Testez la middleware auth dans tinker :" -ForegroundColor White
Write-Host "   php artisan tinker" -ForegroundColor Gray
Write-Host "   User::find(1)->createToken('test-token')" -ForegroundColor Gray

Write-Host "`nFIN DU DEBUG" -ForegroundColor Magenta