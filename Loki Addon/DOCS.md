# Home Assistant Add-on: Mein Grafana Loki

Grafana Loki als Home Assistant Add-on.

## Installation

Folgen Sie diesen Schritten, um das Add-on zu installieren:

1. Fügen Sie mein Repository zu Ihren Home Assistant Add-on Stores hinzu:
   `
   https://github.com/Frogy 76/home-assistant-addons
   `
2. Installieren Sie das "Mein Grafana Loki" Add-on
3. Starten Sie das Add-on
4. Überprüfen Sie die Logs des Add-ons auf Fehler

## Konfiguration

### Option: days_to_keep

Die Anzahl der Tage, für die die Logs aufbewahrt werden sollen. Standardmäßig 30 Tage.

### Option: config_path

Optional: Pfad zu einer benutzerdefinierten Loki-Konfigurationsdatei.

### Option: log_level

Die Protokollierungsebene für Loki. Mögliche Werte sind: 	race, debug, info, 
otice, warning, rror, atal.

## Integration mit Grafana

Nachdem Loki installiert ist, können Sie ihn als Datenquelle in Grafana hinzufügen:

1. Fügen Sie in Grafana eine neue Datenquelle hinzu
2. Wählen Sie Loki als Typ
3. Geben Sie die URL ein: http://IHRE_HOME_ASSISTANT_IP:3100
4. Speichern und testen Sie die Verbindung

## Log-Quellen einrichten

Um Logs in Loki zu senden, können Sie verschiedene Log-Clients verwenden. Eine einfache Methode ist die Verwendung des [Loki-Addons für Fluentd](https://github.com/grafana/loki/tree/main/fluentd/fluent-plugin-grafana-loki), [Fluent Bit](https://github.com/grafana/loki/tree/main/clients/cmd/fluent-bit) oder [Promtail](https://github.com/grafana/loki/tree/main/clients/cmd/promtail).

## Support

Wenn Sie Probleme oder Fragen haben, erstellen Sie bitte ein Issue in meinem [GitHub Repository](https://github.com/Frogy 76/home-assistant-addons).
