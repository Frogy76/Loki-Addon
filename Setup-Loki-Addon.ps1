# PowerShell-Skript zur Korrektur der Repository-Struktur
# Ausführen im Hauptverzeichnis des geklonten Repositories

# Konfigurierbare Parameter (bitte anpassen)
$GitHubUsername = "Frogy76"
$YourName = "Bastian Trompetter"
$YourEmail = "wilier-humor7e@icloud.com"
$CurrentDate = Get-Date -Format "yyyy-MM-dd"

# Konstanten
$RepoPath = Get-Location
$OldAddonDir = "Loki Addon"
$NewAddonDir = "loki-addon"  # Neuer Ordnername ohne Leerzeichen
$RepoUrl = "https://github.com/$GitHubUsername/Loki-Addon"

Write-Host "Starte Korrektur des Repositories..." -ForegroundColor Cyan

# 1. Erstellen oder aktualisieren der repository.yaml im Hauptverzeichnis
$RepositoryYamlContent = @"
name: "Loki Add-on Repository"
url: "$RepoUrl"
maintainer: "$YourName <$YourEmail>"
"@
Set-Content -Path (Join-Path $RepoPath "repository.yaml") -Value $RepositoryYamlContent -Encoding UTF8
Write-Host "✅ repository.yaml im Hauptverzeichnis erstellt/aktualisiert" -ForegroundColor Green

# 2. README.md im Hauptverzeichnis aktualisieren
$ReadmeContent = @"
# Home Assistant Add-on: Loki Repository

## Add-ons

### Grafana Loki
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
Write-Host "✅ README.md im Hauptverzeichnis aktualisiert" -ForegroundColor Green

# 3. Umbenennen des Add-on-Verzeichnisses (falls es existiert)
if (Test-Path (Join-Path $RepoPath $OldAddonDir)) {
    if (Test-Path (Join-Path $RepoPath $NewAddonDir)) {
        Remove-Item -Path (Join-Path $RepoPath $NewAddonDir) -Recurse -Force
    }
    
    # Verzeichnis umbenennen
    Rename-Item -Path (Join-Path $RepoPath $OldAddonDir) -NewName $NewAddonDir
    Write-Host "✅ Add-on-Verzeichnis umbenannt: '$OldAddonDir' -> '$NewAddonDir'" -ForegroundColor Green
}

# 4. config.yaml im Add-on-Verzeichnis korrigieren
$ConfigYamlPath = Join-Path $RepoPath $NewAddonDir "config.yaml"
if (Test-Path $ConfigYamlPath) {
    $ConfigYamlContent = @"
---
name: "Grafana Loki"
version: "1.0.0"
slug: "loki-addon"
description: |
  Grafana Loki ist ein horizontal skalierbares, hochverfügbares, mandantenfähiges Log-Aggregationssystem, inspiriert von Prometheus
arch:
  - aarch64
  - amd64
image: "ghcr.io/$GitHubUsername/ha-addons-loki-{arch}"
startup: system
url: "https://github.com/$GitHubUsername/Loki-Addon"
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
    Set-Content -Path $ConfigYamlPath -Value $ConfigYamlContent -Encoding UTF8
    Write-Host "✅ config.yaml im Add-on-Verzeichnis korrigiert" -ForegroundColor Green
}

# 5. build.yaml im Add-on-Verzeichnis korrigieren
$BuildYamlPath = Join-Path $RepoPath $NewAddonDir "build.yaml"
if (Test-Path $BuildYamlPath) {
    $BuildYamlContent = @"
---
build_from:
  aarch64: "ghcr.io/home-assistant/aarch64-base:3.21"
  amd64: "ghcr.io/home-assistant/amd64-base:3.21"
labels:
  maintainer: "$YourName <$YourEmail>"
  org.opencontainers.image.authors: "$YourName <$YourEmail>"
  org.opencontainers.image.licenses: "MIT License"
  org.opencontainers.image.title: "Home Assistant Add-on: Grafana Loki"
  org.opencontainers.image.url: "https://github.com/$GitHubUsername/Loki-Addon"
  org.opencontainers.image.source: "https://github.com/$GitHubUsername/Loki-Addon/loki-addon"
  org.opencontainers.image.documentation: "https://github.com/$GitHubUsername/Loki-Addon/blob/main/loki-addon/README.md"
  org.opencontainers.image.created: "$CurrentDate"
  org.opencontainers.image.version: "1.0.0"
"@
    Set-Content -Path $BuildYamlPath -Value $BuildYamlContent -Encoding UTF8
    Write-Host "✅ build.yaml im Add-on-Verzeichnis korrigiert" -ForegroundColor Green
}

# 6. DOCS.md im Add-on-Verzeichnis korrigieren
$DocsPath = Join-Path $RepoPath $NewAddonDir "DOCS.md"
if (Test-Path $DocsPath) {
    $DocsContent = @"
# Home Assistant Add-on: Grafana Loki

Grafana Loki als Home Assistant Add-on.

## Installation

Folgen Sie diesen Schritten, um das Add-on zu installieren:

1. Fügen Sie mein Repository zu Ihren Home Assistant Add-on Stores hinzu:
   ```
   https://github.com/$GitHubUsername/Loki-Addon
   ```
2. Installieren Sie das "Grafana Loki" Add-on
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

Wenn Sie Probleme oder Fragen haben, erstellen Sie bitte ein Issue in meinem [GitHub Repository](https://github.com/$GitHubUsername/Loki-Addon).
"@
    Set-Content -Path $DocsPath -Value $DocsContent -Encoding UTF8
    Write-Host "✅ DOCS.md im Add-on-Verzeichnis korrigiert" -ForegroundColor Green
}

# 7. README.md im Add-on-Verzeichnis korrigieren
$AddonReadmePath = Join-Path $RepoPath $NewAddonDir "README.md"
if (Test-Path $AddonReadmePath) {
    $AddonReadmeContent = @"
# Home Assistant Add-on: Grafana Loki

Grafana Loki (<https://grafana.com/oss/loki/>) als Home Assistant Add-on.

## Über dieses Add-on

Grafana Loki ist ein horizontal skalierbares, hochverfügbares, mandantenfähiges Log-Aggregationssystem, inspiriert von Prometheus. Es ist darauf ausgelegt, sehr kosteneffektiv und einfach zu betreiben zu sein. Es indiziert nicht den Inhalt der Logs, sondern ein Set von Labels für jeden Log-Stream.

Dieses Add-on basiert auf dem ursprünglichen Grafana-Loki Add-on von bluemaex, wurde jedoch mit einer aktuelleren Version von Loki (v3.4.5) aktualisiert.

## Hinweise

Für Informationen zur Konfiguration dieses Add-ons, siehe die [Dokumentation](DOCS.md).

Dieses Projekt ist nicht mit Loki affiliiert, sondern ein Community-Projekt. Loki selbst wird unter der [AGPLv3 Lizenz](https://www.gnu.org/licenses/agpl-3.0.de.html) vertrieben.
"@
    Set-Content -Path $AddonReadmePath -Value $AddonReadmeContent -Encoding UTF8
    Write-Host "✅ README.md im Add-on-Verzeichnis korrigiert" -ForegroundColor Green
}

# 8. Änderungen für Git vorbereiten
Write-Host "`nRepository-Struktur erfolgreich korrigiert!" -ForegroundColor Cyan
Write-Host "`nNächste Schritte:" -ForegroundColor Yellow
Write-Host "1. Überprüfen Sie die Änderungen:" -ForegroundColor White
Write-Host "   git status" -ForegroundColor White
Write-Host "2. Fügen Sie alle Änderungen hinzu:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor White
Write-Host "3. Committen Sie die Änderungen:" -ForegroundColor White
Write-Host "   git commit -m 'Korrigiere Repository-Struktur für Home Assistant'" -ForegroundColor White
Write-Host "4. Pushen Sie die Änderungen:" -ForegroundColor White
Write-Host "   git push" -ForegroundColor White
Write-Host "`n5. Fügen Sie das Repository in Home Assistant hinzu:" -ForegroundColor White
Write-Host "   URL: $RepoUrl" -ForegroundColor Green
Write-Host "`nWenn Sie nach dem Push das Repository in Home Assistant aktualisieren möchten," -ForegroundColor White
Write-Host "gehen Sie zum Add-on Store und klicken Sie auf 'Auf Updates prüfen'." -ForegroundColor White