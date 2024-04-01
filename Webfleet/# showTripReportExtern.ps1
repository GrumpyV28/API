# Paramètres
$apiKey = $env:API_KEY
$userName = $env:USER_NAME
$password = $env:PASSWORD
$account = $env:ACCOUNT
$rangePattern = "w-1"   
$eventLevelCur = 1  
$resolved = 0  
$acknowledged = 0 

# Construire l'URL en fonction de l'action avec le driverno et les autres paramètres spécifiques
$actionUrl = "https://csv.webfleet.com/extern?lang=fr&account=$account&username=$userName&password=$password&apikey=$apiKey&action=showTripReportExtern&range_pattern=$rangePattern&eventlevel_cur=$eventLevelCur&resolved=$resolved&acknowledged=$acknowledged"

# Exécuter la requête
try {
    $actionResponse = Invoke-RestMethod -Uri $actionUrl -Method Get

    # Afficher le résultat
    Write-Host "Action showAccelerationEvents effectuée avec succès pour le conducteur $driverNo. Réponse : $($actionResponse | ConvertTo-Json -Depth 5)"

    # Enregistrer la réponse dans un fichier CSV
    $actionResponse | ConvertFrom-Csv -Delimiter ";" | Export-Csv -Path "C:\Matthis\WF_Powershell\showTripReportExtern.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
}
catch {
    Write-Host "Erreur lors de l'exécution de l'action showAccelerationEvents pour le conducteur $driverNo : $($_.Exception.Message)"
}
