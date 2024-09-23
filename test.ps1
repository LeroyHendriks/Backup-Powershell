# Definieer de bronmappen en hun doelbestemmingen
$mapDoelverzameling = @{
    "C:\Test-start" = "C:\Test-destination"
    "C:\Test-start1" = "C:\Test-destination"
}

# Looped door elke bronmap heen en kopieerd deze naar de doelmap
foreach ($bronMap in $mapDoelverzameling.Keys) {
    $doelMap = $mapDoelverzameling[$bronMap]

    # Controleer of de bronmap bestaat
    if (Test-Path $bronMap -PathType Container) {
        Write-Host "Kopiëren van $bronMap naar $doelMap"
        Copy-Item -Path $bronMap -Destination $doelMap -Recurse -Force
        Write-Host "Klaar met kopiëren van $bronMap naar $doelMap"
    } else {
        Write-Warning "Bronmap $bronMap niet gevonden!"
    }
}
