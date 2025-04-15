# Konfigurierbare Parameter
$RepoName = "Loki Add-on Repository"
$RepoUrl = "https://github.com/Frogy76/Loki-Addon"
$YourName = "Ihr Name"
$YourEmail = "ihre.email@beispiel.de"
$AddonName = "mein-grafana-loki"  # Sollte mit dem slug in config.yaml übereinstimmen

# Aktuelles Verzeichnis - sollte das geklonte Repository sein
$RepoPath = Get-Location

# Repository.yaml erstellen
$RepositoryYamlContent = @"
name: $RepoName
url: $RepoUrl
maintainer: $YourName <$YourEmail>
"@
Set-Content -Path (Join-Path $RepoPath "repository.yaml") -Value $RepositoryYamlContent -Encoding UTF8

# README.md für das Repository erstellen
$ReadmeContent = @"
# Home Assistant Add-on: Loki Repository

## Add-ons

### Mein Grafana Loki
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)

> Grafana Loki ist ein horizontal skalierbares, hochverfügbares Log-Aggregationssystem.

## Installation

Um dieses Repository zu installieren:

1. Navigieren Sie in der Home Assistant Oberfläche zu **Einstellungen** -> **Add-ons** -> **Add-on Store**.
2. Klicken Sie auf das Menü in der oberen rechten Ecke und wählen Sie **Repositories**.
3. Fügen Sie folgende URL hinzu: `$RepoUrl`
4. Klicken Sie auf **Hinzufügen**.
5. Nachdem Home Assistant das Repository geladen hat, erscheinen die Add-ons im Store.
"@
Set-Content -Path (Join-Path $RepoPath "README.md") -Value $ReadmeContent -Encoding UTF8

# Überprüfen, ob Add-on im Hauptverzeichnis oder in einem Unterverzeichnis ist
$ConfigYamlPath = Join-Path $RepoPath "config.yaml"
$AddonDirPath = Join-Path $RepoPath $AddonName

if (Test-Path $ConfigYamlPath) {
    # Add-on befindet sich im Hauptverzeichnis - Struktur korrigieren
    Write-Host "Add-on befindet sich im Hauptverzeichnis. Erstelle Unterverzeichnis und verschiebe Dateien..." -ForegroundColor Yellow
    
    # Verzeichnis erstellen
    if (!(Test-Path $AddonDirPath)) {
        New-Item -ItemType Directory -Path $AddonDirPath -Force | Out-Null
    }
    
    # Dateien verschieben, außer README.md und repository.yaml
    Get-ChildItem -Path $RepoPath -Exclude "README.md", "repository.yaml", $AddonName | ForEach-Object {
        $Destination = Join-Path $AddonDirPath $_.Name
        Move-Item -Path $_.FullName -Destination $Destination -Force
        Write-Host "Verschoben: $($_.Name) -> $Destination" -ForegroundColor Green
    }
    
    # config.yaml anpassen, falls nötig
    $ConfigFilePath = Join-Path $AddonDirPath "config.yaml"
    if (Test-Path $ConfigFilePath) {
        $ConfigContent = Get-Content -Path $ConfigFilePath -Raw
        if ($ConfigContent -notmatch "slug:\s*$AddonName") {
            Write-Host "Warnung: Der slug in der config.yaml stimmt möglicherweise nicht mit dem Verzeichnisnamen überein!" -ForegroundColor Red
            Write-Host "Bitte überprüfen Sie die config.yaml und stellen Sie sicher, dass 'slug: $AddonName' enthalten ist." -ForegroundColor Red
        }
    }
}

Write-Host "`nRepository-Struktur wurde korrigiert. Committen und pushen Sie die Änderungen mit:" -ForegroundColor Cyan
Write-Host "git add ." -ForegroundColor White
Write-Host "git commit -m 'Korrigiere Repository-Struktur'" -ForegroundColor White
Write-Host "git push" -ForegroundColor White