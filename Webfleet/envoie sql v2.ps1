param (
    [string]$serverInstance = "SV09BDD032,1435",
    [string]$database = "Webfleet",
    [string]$table = "Acceleration_SABEVI_BELFORT",
    [string]$cheminFichierCSV = "C:\Users\MHERITIER\OneDrive - GROUPE ROGER MARTIN\SQLserver\POWERSHELL\Acceleration_SABEVI BELFORT BETON.csv"
)

# Connexion à la base de données
$connectionString = "Server=$serverInstance;Database=$database;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

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
$csvData = Import-Csv -Path $cheminFichierCSV -Delimiter ';'
foreach ($row in $csvData) {
    $dataRow = $dataTable.NewRow()
    foreach ($column in $columns) {
        $columnName = $column.Trim('"')
        $columnValue = $row.$columnName
        $dataRow[$columnName] = $columnValue

        # Afficher les valeurs pour débogage
        Write-Host "Column: $columnName, Value: $columnValue"
    }
    $dataTable.Rows.Add($dataRow)
}

# Utiliser SqlBulkCopy pour insérer les données dans la base de données
$bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($connection)
$bulkCopy.DestinationTableName = "$table"  # Pas besoin de spécifier la base de données, car elle est déjà définie dans la chaîne de connexion

# Configurer les options de BULK INSERT
# Spécifier un mappage explicite des colonnes
foreach ($column in $columns) {
    $columnName = $column.Trim('"')
    $bulkCopy.ColumnMappings.Add($columnName, $columnName)
}

# Écrire les données dans la base de données
$bulkCopy.WriteToServer($dataTable)

# Fermer la connexion
$connection.Close()
