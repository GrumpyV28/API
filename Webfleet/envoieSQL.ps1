param (
    [string]$serverInstance = "SV09BDD032,1435",
    [string]$database = "Webfleet",
    [string]$table = "Acceleration_SABEVI_BELFORT_BETON",
    [string]$cheminFichierCSV = "W:\00-Commun\0002-Personnel\MHERITIER\Webfleet_2024\Acceleration_SABEVI BELFORT BETON.csv"
)

# Connexion à la base de données
$connectionString = "Server=$serverInstance;Database=$database;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

try {
    # Charger le contenu du fichier CSV
    $fileContent = Get-Content -Path $cheminFichierCSV -Raw

    # Vérifier si la connexion est fermée avant de l'ouvrir
    if ($connection.State -eq 'Closed') {
        $connection.Open()
    }

    # Diviser la première ligne en colonnes
    $columns = $fileContent.Split([System.Environment]::NewLine)[0] -split ';'

    # Créer une DataTable avec les colonnes appropriées
    $dataTable = New-Object System.Data.DataTable

    foreach ($column in $columns) {
        $columnName = $column.Trim('"')
        # Vous pouvez ajuster le type de données en fonction de la structure de votre base de données
        $dataType = [System.String]
        $dataTable.Columns.Add($columnName, $dataType)
    }

    # Charger les données du fichier CSV dans la DataTable
    foreach ($column in $columns) {
        $columnName = $column.Trim('"')
        $value = $row.$columnName
    
        # Convertir la valeur en fonction du type de données de la colonne dans la DataTable
        $dataType = $dataTable.Columns[$columnName].DataType
        try {
            if ($value -ne '') {
                $convertedValue = [System.Convert]::ChangeType($value, $dataType)
            } else {
                $convertedValue = [System.DBNull]::Value
            }
    
            $dataRow[$columnName] = $convertedValue
        } catch {
            Write-Host "Erreur de conversion pour la colonne $columnName avec la valeur '$value'. Type attendu : $dataType"
            throw $_  # Répéter l'exception après avoir affiché l'information de débogage
        }
    }
    



    # Utiliser SqlBulkCopy pour insérer les données dans la base de données
    $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($connection)
    $bulkCopy.DestinationTableName = "[$table]"  # Utiliser des crochets pour le nom de la table

    # Configurer les options de BULK INSERT
    # Spécifier un mappage explicite des colonnes
    foreach ($column in $columns) {
        $columnName = $column.Trim('"')
        $bulkCopy.ColumnMappings.Add($columnName, $columnName)
    }

    # Écrire les données dans la base de données
    $bulkCopy.WriteToServer($dataTable)
}
catch {
    Write-Host "Erreur : $_"
}
finally {
    # Fermer la connexion dans le bloc finally pour s'assurer qu'elle est toujours fermée
    $connection.Close()
}
