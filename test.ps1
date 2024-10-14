# Laad de JSON-configuratie in
if ($configPad = ".\config.json") {
$config = Get-Content $configPad | ConvertFrom-Json
    } else {
        Write-Warning "Pad niet gevonden"
    }

# Looped door elke bronmap heen en kopieert deze naar de doelmap
foreach ($backupPath in $config.backupPaths) {
    $bronMap = $backupPath.source
    $doelMap = $backupPath.destination

    # Controleer of de bronmap bestaat
    if (Test-Path $bronMap -PathType Container) {
        Write-Host "Kopiëren van $bronMap naar $doelMap"
        Copy-Item -Path $bronMap -Destination $doelMap -Recurse -Force
        Write-Host "Klaar met kopiëren van $bronMap naar $doelMap"
    } else {
        Write-Warning "Bronmap $bronMap niet gevonden!"
    }
}

param (
    FullBackup
    Partial
)