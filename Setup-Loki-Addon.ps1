# PowerShell-Skript zur Korrektur der Ausführungsrechte und Loki-Version
# Ausführen im Hauptverzeichnis des geklonten Repositories

# Konstanten
$RepoPath = Get-Location
$AddonDir = "loki-addon"
$DockerfilePath = Join-Path $RepoPath $AddonDir "Dockerfile"

# Funktion zum Aktualisieren der Dockerfile
function Update-Dockerfile {
    param (
        [string]$FilePath
    )
    
    if (!(Test-Path $FilePath)) {
        Write-Host "FEHLER: Die Datei $FilePath wurde nicht gefunden." -ForegroundColor Red
        return $false
    }
    
    try {
        $content = @"
ARG BUILD_FROM

# Hier verwenden wir eine existierende Version von Loki
FROM grafana/loki:2.9.5 as loki-base
FROM `${BUILD_FROM} AS final

# Kopieren der rootfs-Dateien
COPY rootfs /

# Setzen der Ausführungsrechte für Shell-Skripte
RUN chmod a+x /etc/cont-init.d/loki-data-dir.sh \
    && chmod a+x /etc/services.d/loki/finish \
    && chmod a+x /etc/services.d/loki/run

# Kopieren der Loki-Binärdatei aus dem Base-Image
COPY --from=loki-base /usr/bin/loki /usr/bin/loki

# Installation von gomplate
RUN apk add --no-cache gomplate

# Erstellen des Loki-Benutzers
RUN adduser -g "loki" --home /data/loki --disabled-password loki
"@
        
        # Speichern der korrigierten Dockerfile
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
        Write-Host "✅ Dockerfile wurde aktualisiert mit:" -ForegroundColor Green
        Write-Host "  - Loki-Version auf 2.9.5 geändert (existierende Version)" -ForegroundColor Green
        Write-Host "  - chmod-Befehle hinzugefügt, um Ausführungsrechte zu setzen" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FEHLER beim Aktualisieren der Dockerfile: $_" -ForegroundColor Red
        return $false
    }
}

# README.md auch aktualisieren, um die richtige Loki-Version anzuzeigen
function Update-Readme {
    param (
        [string]$FilePath
    )
    
    if (!(Test-Path $FilePath)) {
        Write-Host "WARNUNG: Die Datei $FilePath wurde nicht gefunden. Überspringe..." -ForegroundColor Yellow
        return $false
    }
    
    try {
        $content = Get-Content -Path $FilePath -Raw
        $updatedContent = $content -replace "v3\.4\.[0-9]", "v2.9.5"
        
        # Speichern der korrigierten README.md
        Set-Content -Path $FilePath -Value $updatedContent -Encoding UTF8
        Write-Host "✅ README.md wurde aktualisiert mit der korrekten Loki-Version" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FEHLER beim Aktualisieren der README.md: $_" -ForegroundColor Red
        return $false
    }
}

# CHANGELOG.md aktualisieren
function Update-Changelog {
    param (
        [string]$FilePath
    )
    
    if (!(Test-Path $FilePath)) {
        Write-Host "WARNUNG: Die Datei $FilePath wurde nicht gefunden. Überspringe..." -ForegroundColor Yellow
        return $false
    }
    
    try {
        $content = Get-Content -Path $FilePath -Raw
        $updatedContent = $content -replace "v3\.4\.[0-9]", "v2.9.5"
        
        # Speichern des korrigierten CHANGELOG.md
        Set-Content -Path $FilePath -Value $updatedContent -Encoding UTF8
        Write-Host "✅ CHANGELOG.md wurde aktualisiert mit der korrekten Loki-Version" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FEHLER beim Aktualisieren des CHANGELOG.md: $_" -ForegroundColor Red
        return $false
    }
}

# Hauptprogramm
Write-Host "Starte Korrektur der Dockerfile und Shell-Skript-Berechtigungen..." -ForegroundColor Cyan

# Dockerfile aktualisieren
$dockerfileUpdated = Update-Dockerfile -FilePath $DockerfilePath

# README.md aktualisieren
$readmePath = Join-Path $RepoPath $AddonDir "README.md"
$readmeUpdated = Update-Readme -FilePath $readmePath

# CHANGELOG.md aktualisieren
$changelogPath = Join-Path $RepoPath $AddonDir "CHANGELOG.md"
$changelogUpdated = Update-Changelog -FilePath $changelogPath

if ($dockerfileUpdated) {
    Write-Host "`nÄnderungen wurden erfolgreich angewendet!" -ForegroundColor Green
    
    # Anweisungen für Git
    Write-Host "`nFühren Sie folgende Git-Befehle aus, um die Änderungen zu übernehmen:" -ForegroundColor Yellow
    Write-Host "git add $AddonDir/Dockerfile" -ForegroundColor White
    if ($readmeUpdated) {
        Write-Host "git add $AddonDir/README.md" -ForegroundColor White
    }
    if ($changelogUpdated) {
        Write-Host "git add $AddonDir/CHANGELOG.md" -ForegroundColor White
    }
    Write-Host "git commit -m 'Setze Ausführungsrechte für Shell-Skripte und verwende existierende Loki-Version'" -ForegroundColor White
    Write-Host "git push" -ForegroundColor White
    
    Write-Host "`nNach dem Push überprüfen Sie bitte das Add-on in Home Assistant erneut:" -ForegroundColor Yellow
    Write-Host "1. Gehen Sie zum Add-on Store" -ForegroundColor White
    Write-Host "2. Klicken Sie auf 'Auf Updates prüfen'" -ForegroundColor White
    Write-Host "3. Installieren und starten Sie das Add-on" -ForegroundColor White
}
else {
    Write-Host "`nDie Korrektur konnte nicht angewendet werden. Bitte überprüfen Sie die Dateistruktur." -ForegroundColor Red
}