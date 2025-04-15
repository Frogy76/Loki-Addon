# Home Assistant Add-on: Grafana Loki

Grafana Loki as a Home Assistant add-on.

## Installation

Follow these steps to install the add-on:

1. Add my repository to your Home Assistant add-on stores:
   https://github.com/Frogy76/Loki-Addon
2. Install the "Grafana Loki" add-on
3. Start the add-on
4. Check the add-on logs for errors

## Configuration

### Option: days_to_keep

The number of days to keep logs. Default is 30 days.

### Option: config_path

Optional: Path to a custom Loki configuration file.

### Option: log_level

The logging level for Loki. Possible values are: trace, debug, info, notice, warning, error, fatal.

### Option: resource_limits

Resource limit configuration:
- **memory**: Memory limit for Loki (e.g., "256M", "1G")
- **cpu_percent**: CPU usage limit in percent (10-100)

### Option: security

Security settings:
- **enable_auth**: Enable authentication (true/false)
- **username**: Username for authentication
- **password**: Password for authentication

### Option: advanced

Advanced settings:
- **max_chunk_size**: Maximum size of chunks in bytes
- **max_query_series**: Maximum number of series that can be returned in a query
- **max_query_lookback**: Maximum time period for backward queries (e.g., "720h" for 30 days)

## Integration with Grafana

After installing Loki, you can add it as a data source in Grafana:

1. In Grafana, add a new data source
2. Select Loki as the type
3. Enter the URL: http://YOUR_HOME_ASSISTANT_IP:3100
4. Save and test the connection

## Setting up Log Sources

To send logs to Loki, you can use various log clients. A simple method is to use the [Loki plugin for Fluentd](https://github.com/grafana/loki/tree/main/fluentd/fluent-plugin-grafana-loki), [Fluent Bit](https://github.com/grafana/loki/tree/main/clients/cmd/fluent-bit), or [Promtail](https://github.com/grafana/loki/tree/main/clients/cmd/promtail).

Example configurations can be found in the /examples directory of this add-on.

## Support

If you have problems or questions, please create an issue in my [GitHub Repository](https://github.com/Frogy76/Loki-Addon).
