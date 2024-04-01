param (
    [string]$serverInstance = "SV09BDD032,1435",
    [string]$database = "Webfleet"
)

# Liste des groupes
$listeGroupes = @(
    'DEMONGEOT',
    'ERM GRAND TRAVAUX',
    'SABEVI BELFORT BETON',
    'SABEVI BESANCON BETON',
    'SABEVI BOURGOGNE BETON',
    'ERM LEVIER',
    'RM AURA - MOULIN ENVIRONNEMENT',
    'AXIROUTE',
    'MERLOT TP',
    'ERM BELFORT',
    'ERM DANNEMARIE',
    'RM AURA - CANTAL',
    'RM AURA - MOULIN TP',
    'RM AURA - ISERE LOIRE RHONE',
    'RM AURA - AIN',
    'SETEC',
    'ERM SAINT APOLLINAIRE',
    'ERM TROYES',
    'ERM VESOUL',
    'ERM DOLE',
    'SODIBE',
    'ERM LABO CENTRAL',
    'RM AURA - REGION',
    'SNCTP MATERIEL',
    'HENRI MARTIN',
    'RM FACILITIES',
    'SNCTP BAT',
    'SNCTP CANA BESANCON',
    'SNCTP CANA CHASSIEU',
    'SNCTP CANA CHAUMONT',
    'SNCTP CANA DIJON',
    'SNCTP CANA DOLE',
    'SNCTP CANA MACON',
    'SNCTP CANA MONTCEAU',
    'SNCTP CANA TROYES',
    'SNCTP GENIE CIVIL'
)

foreach ($groupe in $listeGroupes) {
    $table = "Acceleration_$groupe"
    $cheminFichierCSV = "W:\00-Commun\0002-Personnel\MHERITIER\Webfleet_2024\Acceleration_$groupe.csv"

    $connectionString = "Server=$serverInstance;Database=$database;Integrated Security=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString

    try {
        # Charger le contenu du fichier CSV
        $fileContent = Get-Content -Path $cheminFichierCSV -Raw -ErrorAction Stop | Out-Null

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
            $dataType = [System.String]
            $dataTable.Columns.Add($columnName, $dataType)
        }

        # Charger les données du fichier CSV dans la DataTable
        $csvData = Import-Csv -Path $cheminFichierCSV -Delimiter ';' -ErrorAction Stop | Out-Null
        foreach ($row in $csvData) {
            $dataRow = $dataTable.NewRow()
            foreach ($column in $columns) {
                $columnName = $column.Trim('"')
                $dataRow[$columnName] = $row.$columnName
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
    }
    catch {
        Write-Error "Erreur : $_" -ErrorAction Continue
    }
    finally {
        # Fermer la connexion dans le bloc finally pour s'assurer qu'elle
        $connection.Close()
    }
}