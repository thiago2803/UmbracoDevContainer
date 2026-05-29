param(
  [string]$CertPassword = $env:DEVCONTAINER_CERT_PASSWORD
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($CertPassword)) {
  $CertPassword = 'devcontainer-local-password'
}

$certDirectory = Join-Path $PSScriptRoot 'https'
$certPath = Join-Path $certDirectory 'devcontainer-https.pfx'

if (-not (Test-Path $certDirectory)) {
  New-Item -ItemType Directory -Path $certDirectory -Force | Out-Null
}

dotnet dev-certs https --trust | Out-Null

if (Test-Path $certPath) {
  Remove-Item $certPath -Force
}

dotnet dev-certs https -ep $certPath -p $CertPassword
Write-Host "Refreshed shared dev certificate at $certPath"