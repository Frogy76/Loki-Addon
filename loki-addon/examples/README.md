# Loki Add-on Examples

This directory contains example configurations for Loki and its clients.

## Contents

- custom-loki-config.yaml: A proven custom configuration for Loki with improved performance settings
- promtail-config.yaml: Example configuration for Promtail to collect Home Assistant logs

## Using Custom Loki Configuration

To use the custom Loki configuration:

1. Copy the custom-loki-config.yaml file to a location accessible by Home Assistant
2. In the Loki add-on configuration, set the config_path to the path of your copied file
3. Restart the Loki add-on

## Using Promtail Configuration

To set up Promtail:

1. Install Promtail on your system
2. Adjust the configuration file as needed (particularly the paths to your log files)
3. Configure Promtail to point to your Loki instance
4. Start Promtail

