# Paramètres
$apiKey = "a00ab50e-32db-41f3-bfe8-c436a920ab7b"
$userName = "Clugand"
$password = "RM-21-geoloc"
$account = "rogermartin"
$msgClass = 0

$createQueueUrl = "https://csv.webfleet.com/extern?lang=en&account=$account&username=$userName&password=$password&apikey=$apiKey&action=createQueueExtern&msgclass=$msgClass"

try {
    $createQueueResponse = Invoke-RestMethod -Uri $createQueueUrl -Method Get
    Write-Host "File d'attente créée avec succès. Réponse : $($createQueueResponse | ConvertTo-Json -Depth 5)"
    $createQueueResponse | Export-Csv -Path "C:\Matthis\WF_Powershell\CreateQueueResponse.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
}
catch {
    Write-Host "Erreur lors de la création de la file d'attente : $($_.Exception.Message)"
}

$listActions = "showObjectReportExtern,showVehicleReportExtern,showContracts,showObjectGroups,showObjectGroupObjects,getObjectCanMalfunctions,getElectricVehicleData,showDriverReportExtern,
showDriverGroups,showDriverGroupDrivers,showAddressReportExtern,showAddressGroupReportExtern,showAddressGroupAddressReportExtern,getVehicleConfig,showUsers,showMaintenanceSchedules,
getReportList,getAreas,getLocalAuxDeviceConfig".Replace("`n", "").Split(",")

foreach ($Action in $listActions) {
    try {
        # Construire l'URL en fonction de l'action
        $actionUrl = "https://csv.webfleet.com/extern?lang=en&account=$account&username=$userName&password=$password&apikey=$apiKey&action=$Action"

        # Exécuter la requête
        $actionResponse = Invoke-RestMethod -Uri $actionUrl -Method Get

        # Afficher le résultat
        Write-Host "Action $Action effectuée avec succès. Réponse : $($actionResponse | ConvertTo-Json -Depth 5)"

        # Enregistrer la réponse dans un fichier CSV
        $actionResponse | ConvertFrom-Csv -Delimiter ";" | Export-Csv -Path "C:\Matthis\WF_Powershell\$Action.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    }
    catch {
        Write-Host "Erreur lors de l'exécution de l'action $Action : $($_.Exception.Message)"
    }
}
