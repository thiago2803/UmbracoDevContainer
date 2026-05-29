# Umbraco Dev Container Starter

Starter site for a clean Umbraco installation running inside a VS Code dev container.

This repository includes:

- Umbraco CMS + Umbraco Forms on .NET 10
- A dev container with supporting local services
- SQL Server for Umbraco data
- Azurite (Azure Storage emulator)
- Azure App Configuration emulator with seeded development values
- .NET Aspire Dashboard for traces, metrics, and logs via OpenTelemetry

## Solution structure

- Application: src/UmbracoWeb/UmbracoWeb.csproj
- Solution file: UmbracoDevContainer.slnx
- Dev container config: .devcontainer/devcontainer.json
- Compose services: .devcontainer/docker-compose.yml
- App Configuration seed data: infra/appconfig/appconfig.dev.json

## Prerequisites

- Docker Desktop (running)
- Visual Studio Code
- Dev Containers extension for VS Code
- .NET SDK installed on the host (used by dev certificate setup)

## Quick start

1. Create your local environment file.

	Copy .env.example to .env and adjust values if needed:
	Copy .env.example to .devcontainer/.env and adjust values if needed:

	cp .env.example .devcontainer/.env

	- UMBRACO_USER_NAME
	- UMBRACO_USER_EMAIL
	- UMBRACO_USER_PASSWORD
	- SQL_SA_PASSWORD
	- DEVCONTAINER_CERT_PASSWORD

2. Open the repository in VS Code.

3. Reopen in container.

	Use the command palette:

	- Dev Containers: Reopen in Container

4. Start the web app.

	Use Run and Debug and select:

	- C#: UmbracoWeb Debug

	Or run from terminal inside container:

	dotnet run --project src/UmbracoWeb/UmbracoWeb.csproj

5. Open the site URL shown in the debug output.

	Default local URLs are typically:

	- https://localhost:44308
	- http://localhost:31619

## What the dev container starts

When the container starts, it launches these services:

- sql: Microsoft SQL Server Developer edition
- azurite: Azure Storage emulator
- appconfig: Azure App Configuration emulator
- aspire-dashboard: local telemetry dashboard

The post-start script imports key-values from infra/appconfig/appconfig.dev.json into the App Configuration emulator.

## Observability

OpenTelemetry is configured in Program.cs with ASP.NET Core, HTTP client, and runtime instrumentation.

Telemetry and logs are exported to Aspire Dashboard:

- Dashboard UI: http://localhost:18888
- OTLP endpoint: http://localhost:18889

## Build

From inside the dev container:

dotnet build UmbracoDevContainer.slnx

Or run the VS Code task:

- dotnet: build

## First run behavior

- Temporary limitation: create the UmbracoDb database manually before first run.
- Umbraco admin credentials can be provided through the environment variables in .devcontainer/.env.
- HTTPS development certificate is generated and shared for container use from .devcontainer/https/devcontainer-https.pfx.

## Troubleshooting

### Database does not exist on startup

For now, the database must be created manually. Automatic database creation is planned to be fixed later.

Create the database from inside the SQL container:

```bash
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SQL_SA_PASSWORD" -No -Q "IF DB_ID(N'UmbracoDb') IS NULL CREATE DATABASE [UmbracoDb];"
```

### SQL login or connection errors

- Verify SQL_SA_PASSWORD in .devcontainer/.env matches the SQL container configuration.
- Confirm the connection string target is sql,1433 inside the container network.
- Rebuild/reopen the dev container after changing .devcontainer/.env values.

### HTTPS certificate issues

- Rebuild the dev container if the certificate file is missing.
- Ensure DEVCONTAINER_CERT_PASSWORD in .devcontainer/.env matches the configured Kestrel certificate password.

### App Configuration import warnings

- On startup, the post-start script retries App Configuration import.
- If the emulator is not ready or auth is unavailable, import may be skipped and startup will continue.

## Notes

- This repository is intended as a clean starting point.
- Content types, templates, and custom code can be added on top of this baseline.

## Contributing

1. Create a branch for your change.
2. Keep changes focused and small.
3. Build locally in the dev container.
4. Open a pull request with a clear description of the change.