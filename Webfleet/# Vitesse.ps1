# Paramètres
$apiKey = $env:API_KEY
$userName = $env:USER_NAME
$password = $env:PASSWORD
$account = $env:ACCOUNT
$rangePattern = "m-3"   
$eventLevelCur = 1  
$resolved = 0  
$acknowledged = 0 

# Groupe de conducteurs
$driverGroupName = "SABEVI BELFORT BETON,SABEVI BESANCON BETON,SABEVI BOURGOGNE BETON,RM AURA - MOULIN ENVIRONNEMENT,AXIROUTE,MERLOT TP,ERM BELFORT,ERM DANNEMARIE,RM AURA - CANTAL,RM AURA - ISERE LOIRE RHONE,RM AURA - AIN,SETEC,ERM SAINT APOLLINAIRE,ERM TROYES,ERM VESOUL,ERM DOLE,SODIBE,ERM AGT/AGTE,ERM LABO CENTRAL,RM AURA - REGION,RM AURA - MOULIN TP,SNCTP MATERIEL,ALL_ROGER_MARTIN,ALL_SNCTP,DEMONGEOT,ERM leviers,RM FACILITIES,ERM GRAND TRAVAUX".Split(",")


# Compteur de requêtes
$requestCounter = 0

foreach ($GroupName in $driverGroupName){
    # Exécuter la requête
    try {
        # Incrémenter le compteur de requêtes
        $requestCounter++
        
        
        # Si 10 requêtes ont été effectuées, faire une pause de 1 minute (60 secondes)
        if ($requestCounter -eq 10) {
            # Wait for 60 seconds
            for ($i = 1; $i -le 60; $i++) {
                Write-Progress -Activity "Waiting" -Status "10 requêtes ont été effectuées, pause de 1 minute" -PercentComplete ($i / 60 * 100)
                Start-Sleep -Seconds 1
            }
            $requestCounter = 0 
        }
            
        # Construire l'URL 
        
        $actionUrl = "https://csv.webfleet.com/extern?lang=fr&account=$account&username=$userName&password=$password&apikey=$apiKey&action=showAccelerationEvents&drivergroupname=$GroupName&range_pattern=$rangePattern&eventlevel_cur=$eventLevelCur&resolved=$resolved&acknowledged=$acknowledged"
        
        
        Write-Host "Chargement des données du groupe $GroupName"
        $actionResponse = Invoke-RestMethod -Uri $actionUrl -Method Get
        
        
        # Remplacement du caracteres /
        if ($GroupName -match '/')   { $GroupName=$GroupName.replace('/',"-") }
        
        
        # Enregistrer la réponse dans un fichier CSV
        Write-Host "Ecriture du groupe $GroupName"
        
        $actionResponse | ConvertFrom-Csv -Delimiter ";" | Export-Csv -Path "W:\00-Commun\0002-Personnel\MHERITIER\Webfleet_2024\Acceleration_$GroupName.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
        #$actionResponse | Set-Content -Path "C:\Users\MHERITIER\OneDrive - GROUPE ROGER MARTIN\WF_test\Acceleration_$GroupName.csv" 
        
        
    }
    catch {
        Write-Host "Erreur lors de l'exécution de l'action showAccelerationEvents pour le groupe $GroupName : $($_.Exception.Message)"
    }
}
