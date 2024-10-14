# To Do
# - Parameters
# - Bestanden zippen
# - Username met timestamps map
# - Error handeling
# - Automatisch Elevation

# Parameters
# param (
#     FullBackup
#     Partial
# )

# Funtions

# Full Backup
function FullBackup {
    Clear-Host

    Write-Host  -ForegroundColor 'Red' "
    ---------------------------------------------
    *                Full Backup                *
    ---------------------------------------------
    "

    # Het pad naar het JSON-configuratiebestand
    $BackupconfigPad = ".\config\fbconfig.json"

    # Controleren of het configuratiebestand bestaat
    if (-not (Test-Path $BackupconfigPad)) {
        $CreateNewBackupConfig = Read-Host "Geen configuratiebestand gevonden in '$BackupconfigPad'. Wil je een nieuw bestand aanmaken? (Y/N)"
        if ($CreateNewBackupConfig -eq "Y" -or $CreateNewBackupConfig -eq "y") {
            # Content config file
            $SampleData = @'
{
    "backupPaths": [
        {
            "source": "C:\\Users\\Beheerder",
            "destination": "C:\\Backup"
        }
    ]
}
'@

            # Het JSON-bestand aanmaken
            $SampleData | Out-File -FilePath $BackupconfigPad -Encoding utf8
            Write-Host "Het configuratiebestand $BackupconfigPad is aangemaakt!"
        } else {
            Write-Host "Script wordt afgebroken, omdat er geen config file bestaat!"
            pause
        }
    }

    # Configuratiebestand laden
    $configData = Get-Content -Raw -Path $BackupconfigPad | ConvertFrom-Json

    # Voor elke backup in het JSON-bestand de bron en bestemming kopiëren
    foreach ($path in $configData.backupPaths) {
        $source = $path.source
        $destination = $path.destination

        Write-Host "Back-uppen van $source naar $destination..."

        # Controleren of de bronmap bestaat
        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $destination -Recurse -Force
            # Kopieer alle bestanden en submappen van de bron naar de bestemming
            Write-Host "Backup van $source naar $destination voltooid!"
        } else {
            Write-Host "Fout: De bronmap $source bestaat niet."
        }
    }
}

# Functie om een partial backup uit te voeren
function PartialBackup {
    Clear-Host

    Write-Host  -ForegroundColor 'Red' "
    ---------------------------------------------
    *              Partial Backup          *
    ---------------------------------------------
    "

    # Pad naar het JSON-configuratiebestand
    $BackupconfigPad = ".\config\fbconfig.json"

    # Controleren of het configuratiebestand bestaat
    if (-not (Test-Path $BackupconfigPad)) {
        Write-Host "Configuratiebestand '$BackupconfigPad' niet gevonden. Maak eerst een volledige backup."
        pause
        return
    }

    # Configuratiegegevens laden
    $configData = Get-Content -Raw -Path $BackupconfigPad | ConvertFrom-Json

    # Voor elke backup-pad in het JSON-bestand
    foreach ($path in $configData.backupPaths) {
        $source = $path.source
        $destination = $path.destination

        Write-Host "Gedeeltelijke backup uitvoeren van $source naar $destination..."

        # Controleren of de bronmap bestaat
        if (Test-Path $source) {
            # Haal de laatste backup-timestamp op voor dit pad
            $lastBackupTime = $path.lastBackupTime

            # Zoek bestanden die zijn gewijzigd sinds de laatste backup
            $filesToBackup = Get-ChildItem -Path $source -Recurse | Where-Object { $_.LastWriteTime -gt $lastBackupTime }

            # Kopieer de nieuwe bestanden naar de bestemmingsmap
            foreach ($file in $filesToBackup) {
                $destinationFile = Join-Path -Path $destination -ChildPath $file.FullName.Substring($source.Length + 1)
                Write-Host "Kopieer $($file.FullName) naar $($destinationFile)"
                Copy-Item -Path $file.FullName -Destination $destinationFile -Force
            }

            # Update de laatste backup-tijd in de configuratie
            $path.lastBackupTime = Get-Date

            Write-Host "Gedeeltelijke backup van $source naar $destination voltooid!"
        } else {
            Write-Host "Fout: Bronmap $source bestaat niet."
        }
    }

    # Opslaan van bijgewerkte configuratie naar het bestand
    $configData | ConvertTo-Json -Depth 5 | Set-Content -Path $FBconfigPad -Encoding utf8

    Write-Host "Gedeeltelijke backup-proces voltooid."
}

# Main menu
do {
    Clear-Host

    Write-Host  -ForegroundColor 'Red' "
    ---------------------------------------------
    *                Main Menu                  *
    ---------------------------------------------
    "
    Write-Host "Select an option:"

    Write-Host "------------------------------------------------------------------------"

    Write-Host "1. Full Back-up"
    Write-Host "2. Partial Back-up"

    Write-Host "------------------------------------------------------------------------"

    Write-Host "0. Exit this program"

    Write-Host "------------------------------------------------------------------------"

    $choice = Read-Host "Select (1, 2 or 0)"

    switch ($choice) {
        "1" { FullBackup }
        "2" { PartialBackup }
        "0" { Write-Host "Goodbye..."; break }
        default { Write-Host "Improper choice. Please try again."; pause }
    }
} while ($choice -ne "0")