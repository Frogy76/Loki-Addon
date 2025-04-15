# PowerShell-Skript zum Erstellen eines Grafana-Loki Add-ons für Home Assistant
# Basierend auf dem bestehenden Add-on von bluemaex

# Konfigurierbare Parameter
$AddonName = "Loki Addon"
$GitHubUsername = "Frogy 76"
$YourName = "Bastian Trompetter"
$YourEmail = "wilier-humor7e@icloud.com"
$LokiVersion = "3.4.5"  # Neuere Version von Loki
$AddonVersion = "1.0.0"
$BaseRepositoryUrl = "https://raw.githubusercontent.com/bluemaex/home-assistant-addons/master/grafana-loki"
$TempDir = Join-Path $env:TEMP "ha-addon-tmp"
$CurrentDate = Get-Date -Format "yyyy-MM-dd"

# Zielpfad für das neue Add-on
$AddonRootPath = Join-Path (Get-Location) $AddonName

# Funktion zum Herunterladen von Dateien
function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath
    )
    
    $Directory = Split-Path -Path $OutputPath -Parent
    if (!(Test-Path -Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -ErrorAction Stop
        Write-Host "Heruntergeladen: $Url -> $OutputPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Fehler beim Herunterladen von $Url`: $_" -ForegroundColor Red
    }
}

# Funktion zum Erstellen von Dateien mit Inhalt
function Create-File {
    param (
        [string]$Path,
        [string]$Content
    )
    
    $Directory = Split-Path -Path $Path -Parent
    if (!(Test-Path -Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    Set-Content -Path $Path -Value $Content -Encoding UTF8
    Write-Host "Datei erstellt: $Path" -ForegroundColor Green
}

# Hauptprogramm
try {
    # Temporäres Verzeichnis erstellen und bereinigen
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    
    # Zielverzeichnis erstellen
    if (!(Test-Path $AddonRootPath)) {
        New-Item -ItemType Directory -Path $AddonRootPath -Force | Out-Null
        Write-Host "Add-on-Verzeichnis erstellt: $AddonRootPath" -ForegroundColor Cyan
    }
    else {
        Write-Host "Warnung: Verzeichnis $AddonRootPath existiert bereits. Bestehende Dateien könnten überschrieben werden." -ForegroundColor Yellow
    }
    
    # Rootfs-Verzeichnisstruktur erstellen
    $RootfsBasePath = Join-Path $AddonRootPath "rootfs"
    $ContInitDPath = Join-Path $RootfsBasePath "etc\cont-init.d"
    $LokiConfigPath = Join-Path $RootfsBasePath "etc\loki"
    $ServicesDPath = Join-Path $RootfsBasePath "etc\services.d\loki"
    
    New-Item -ItemType Directory -Path $ContInitDPath -Force | Out-Null
    New-Item -ItemType Directory -Path $LokiConfigPath -Force | Out-Null
    New-Item -ItemType Directory -Path $ServicesDPath -Force | Out-Null
    
    # Dateien vom Original-Add-on herunterladen
    $FilesToDownload = @(
        @{Url = "$BaseRepositoryUrl/rootfs/etc/cont-init.d/loki-data-dir.sh"; Path = Join-Path $ContInitDPath "loki-data-dir.sh"},
        @{Url = "$BaseRepositoryUrl/rootfs/etc/loki/default-config.yaml"; Path = Join-Path $LokiConfigPath "default-config.yaml"},
        @{Url = "$BaseRepositoryUrl/rootfs/etc/services.d/loki/finish"; Path = Join-Path $ServicesDPath "finish"},
        @{Url = "$BaseRepositoryUrl/rootfs/etc/services.d/loki/run"; Path = Join-Path $ServicesDPath "run"}
    )
    
    foreach ($File in $FilesToDownload) {
        Download-File -Url $File.Url -OutputPath $File.Path
    }
    
    # Dateiberechtigungen für Shell-Skripte setzen (im Windows-Kontext nicht relevant, aber dokumentiert)
    Write-Host "Hinweis: Unter Linux müssten Sie die Ausführungsberechtigungen für die Shell-Skripte setzen:" -ForegroundColor Yellow
    Write-Host "chmod +x $ContInitDPath/loki-data-dir.sh" -ForegroundColor Yellow
    Write-Host "chmod +x $ServicesDPath/finish" -ForegroundColor Yellow
    Write-Host "chmod +x $ServicesDPath/run" -ForegroundColor Yellow
    
    # Neue Dateien mit angepasstem Inhalt erstellen
    
    # Dockerfile
    $DockerfileContent = @"
ARG BUILD_FROM

# Hier verwenden wir eine neuere Version von Loki
FROM grafana/loki:$LokiVersion as loki-base
FROM `${BUILD_FROM} AS final

COPY rootfs /
COPY --from=loki-base /usr/bin/loki /usr/bin/loki

RUN apk add --no-cache gomplate

RUN adduser -g "loki" --home /data/loki --disabled-password loki
"@
    Create-File -Path (Join-Path $AddonRootPath "Dockerfile") -Content $DockerfileContent
    
    # config.yaml
    $ConfigYamlContent = @"
---
name: Mein Grafana Loki
version: $AddonVersion
slug: $AddonName
description: |
  Grafana Loki ist ein horizontal skalierbares, hochverfügbares, mandantenfähiges Log-Aggregationssystem, inspiriert von Prometheus
arch:
  - aarch64
  - amd64
image: "ghcr.io/$GitHubUsername/ha-addons-loki-{arch}"
startup: system
url: https://github.com/$GitHubUsername/home-assistant-addons/tree/master/$AddonName
init: false
ports:
  3100/tcp: 3100
ports_description:
  3100/tcp: Loki listen port
panel_icon: mdi:router-network
map:
  - config
  - share
options:
  days_to_keep: 30
  log_level: info
schema:
  days_to_keep: int(1,)?
  config_path: str?
  log_level: list(trace|debug|info|notice|warning|error|fatal)?
"@
    Create-File -Path (Join-Path $AddonRootPath "config.yaml") -Content $ConfigYamlContent
    
    # build.yaml
    $BuildYamlContent = @"
---
build_from:
  aarch64: "ghcr.io/home-assistant/aarch64-base:3.21"
  amd64: "ghcr.io/home-assistant/amd64-base:3.21"
labels:
  maintainer: "$YourName <$YourEmail>"
  org.opencontainers.image.authors: "$YourName <$YourEmail>"
  org.opencontainers.image.licenses: "MIT License"
  org.opencontainers.image.title: "Home Assistant Add-on: Mein Grafana-Loki"
  org.opencontainers.image.url: https://github.com/$GitHubUsername/home-assistant-addons
  org.opencontainers.image.source: https://github.com/$GitHubUsername/home-assistant-addons/$AddonName
  org.opencontainers.image.documentation: https://github.com/$GitHubUsername/home-assistant-addons/$AddonName/README.md
  org.opencontainers.image.created: "$CurrentDate"
  org.opencontainers.image.version: $AddonVersion
"@
    Create-File -Path (Join-Path $AddonRootPath "build.yaml") -Content $BuildYamlContent
    
    # README.md
    $ReadmeContent = @"
# Home Assistant Add-on: Mein Grafana Loki

Grafana Loki (<https://grafana.com/oss/loki/>) als Home Assistant Add-on.

## Über dieses Add-on

Grafana Loki ist ein horizontal skalierbares, hochverfügbares, mandantenfähiges Log-Aggregationssystem, inspiriert von Prometheus. Es ist darauf ausgelegt, sehr kosteneffektiv und einfach zu betreiben zu sein. Es indiziert nicht den Inhalt der Logs, sondern ein Set von Labels für jeden Log-Stream.

Dieses Add-on basiert auf dem ursprünglichen Grafana-Loki Add-on von bluemaex, wurde jedoch mit einer aktuelleren Version von Loki (v$LokiVersion) aktualisiert.

## Hinweise

Für Informationen zur Konfiguration dieses Add-ons, siehe die [Dokumentation](DOCS.md).

Dieses Projekt ist nicht mit Loki affiliiert, sondern ein Community-Projekt. Loki selbst wird unter der [AGPLv3 Lizenz](https://www.gnu.org/licenses/agpl-3.0.de.html) vertrieben.
"@
    Create-File -Path (Join-Path $AddonRootPath "README.md") -Content $ReadmeContent
    
    # DOCS.md
    $DocsContent = @"
# Home Assistant Add-on: Mein Grafana Loki

Grafana Loki als Home Assistant Add-on.

## Installation

Folgen Sie diesen Schritten, um das Add-on zu installieren:

1. Fügen Sie mein Repository zu Ihren Home Assistant Add-on Stores hinzu:
   ```
   https://github.com/$GitHubUsername/home-assistant-addons
   ```
2. Installieren Sie das "Mein Grafana Loki" Add-on
3. Starten Sie das Add-on
4. Überprüfen Sie die Logs des Add-ons auf Fehler

## Konfiguration

### Option: `days_to_keep`

Die Anzahl der Tage, für die die Logs aufbewahrt werden sollen. Standardmäßig 30 Tage.

### Option: `config_path`

Optional: Pfad zu einer benutzerdefinierten Loki-Konfigurationsdatei.

### Option: `log_level`

Die Protokollierungsebene für Loki. Mögliche Werte sind: `trace`, `debug`, `info`, `notice`, `warning`, `error`, `fatal`.

## Integration mit Grafana

Nachdem Loki installiert ist, können Sie ihn als Datenquelle in Grafana hinzufügen:

1. Fügen Sie in Grafana eine neue Datenquelle hinzu
2. Wählen Sie Loki als Typ
3. Geben Sie die URL ein: `http://IHRE_HOME_ASSISTANT_IP:3100`
4. Speichern und testen Sie die Verbindung

## Log-Quellen einrichten

Um Logs in Loki zu senden, können Sie verschiedene Log-Clients verwenden. Eine einfache Methode ist die Verwendung des [Loki-Addons für Fluentd](https://github.com/grafana/loki/tree/main/fluentd/fluent-plugin-grafana-loki), [Fluent Bit](https://github.com/grafana/loki/tree/main/clients/cmd/fluent-bit) oder [Promtail](https://github.com/grafana/loki/tree/main/clients/cmd/promtail).

## Support

Wenn Sie Probleme oder Fragen haben, erstellen Sie bitte ein Issue in meinem [GitHub Repository](https://github.com/$GitHubUsername/home-assistant-addons).
"@
    Create-File -Path (Join-Path $AddonRootPath "DOCS.md") -Content $DocsContent
    
    # CHANGELOG.md
    $ChangelogContent = @"
# Changelog

## Mein Grafana Loki $AddonVersion - $CurrentDate

### Änderungen

- Erste Version basierend auf dem Grafana-Loki Add-on von bluemaex
- Aktualisierung auf Loki v$LokiVersion
- Anpassungen in der Konfiguration und Dokumentation
"@
    Create-File -Path (Join-Path $AddonRootPath "CHANGELOG.md") -Content $ChangelogContent
    
    # Abschluss
    Write-Host "`nDas Add-on wurde erfolgreich erstellt unter: $AddonRootPath" -ForegroundColor Cyan
    Write-Host "Bitte ersetzen Sie folgende Platzhalter in den Dateien, falls Sie sie nicht bereits im Skript konfiguriert haben:" -ForegroundColor Yellow
    Write-Host "- BITTE_ERSETZEN: Ihr GitHub-Benutzername und Ihre Kontaktdaten" -ForegroundColor Yellow
    Write-Host "`nNächste Schritte:" -ForegroundColor Cyan
    Write-Host "1. Erstellen Sie ein GitHub-Repository für Ihr Add-on" -ForegroundColor White
    Write-Host "2. Führen Sie folgende Git-Befehle aus, um das Add-on hochzuladen:" -ForegroundColor White
    Write-Host "   git init" -ForegroundColor White
    Write-Host "   git add ." -ForegroundColor White
    Write-Host "   git commit -m 'Erstes Commit: Mein Grafana Loki Add-on'" -ForegroundColor White
    Write-Host "   git remote add origin https://github.com/$GitHubUsername/home-assistant-addons.git" -ForegroundColor White
    Write-Host "   git push -u origin master" -ForegroundColor White
    Write-Host "3. Richten Sie GitHub Actions ein, um den Container automatisch zu bauen (optional)" -ForegroundColor White
    Write-Host "4. Installieren Sie das Add-on in Home Assistant, indem Sie Ihr Repository hinzufügen" -ForegroundColor White
}
catch {
    Write-Host "Ein Fehler ist aufgetreten: $_" -ForegroundColor Red
}
finally {
    # Aufräumen
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force
    }
}