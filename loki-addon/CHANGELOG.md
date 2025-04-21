# Changelog

## Grafana Loki 1.0.8 - 2025-04-21
### Changes

- Removed the backup service script

## Grafana Loki 1.0.6 - 2025-04-17
### Changes

- Fixed backup service script error with bashio API calls
- Added proper error handling for backup file operations
- Added JQ as dependency in Dockerfile for API responses processing
- Improved script execution permissions handling

## Grafana Loki 1.0.5 - 2025-04-17
### Changes

- Switch to home-assistant/aarch64-base:3.21

## Grafana Loki 1.0.3 - 2025-04-17
### Changes

- Fixed backup service script to use proper Supervisor API calls instead of non-existent functions
- Improved error handling in backup process
- Updated comments in backup service for better maintainability

## Grafana Loki 1.0.2 - 2025-04-17
### Changes

- Fixed permission issue: Added execute permissions for all run scripts, especially for the backup service script
- Fixed "Permission denied" error in S6 supervision

## Grafana Loki 1.0.1 - 2025-04-15
### Changes

- First version based on Grafana-Loki add-on by bluemaex
- Updated to Loki v3.4.3
- Adjustments to configuration and documentation