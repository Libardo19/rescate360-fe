# Pone la URL del túnel del API en la app (config/demo.json) y en el panel (rescate360-web/.env.tunel).
# Uso:  .\scripts\usar-tunel.ps1 -Url https://xxxx.trycloudflare.com
param([Parameter(Mandatory = $true)][string]$Url)

$ErrorActionPreference = 'Stop'
$Url = $Url.TrimEnd('/')
$uri = [Uri]$Url
if (-not $uri.IsAbsoluteUri -or $uri.Scheme -ne 'https') { throw 'La URL del túnel debe empezar por https://' }

$salud = Invoke-RestMethod -Uri "$Url/health/ready" -TimeoutSec 20
if ($salud.status -ne 'ok') { throw 'El API no responde por ese túnel (¿está corriendo el backend?).' }

$repo = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$demo = Join-Path $repo 'config/demo.json'
$config = Get-Content -LiteralPath $demo -Raw | ConvertFrom-Json
$config.API_BASE_URL = $Url
[IO.File]::WriteAllText($demo, ($config | ConvertTo-Json) + "`n", $utf8)

$envTunel = Join-Path $repo 'rescate360-web/.env.tunel'
$texto = (Get-Content -LiteralPath $envTunel -Raw) -replace '(?m)^VITE_API_URL=.*$', "VITE_API_URL=$Url"
[IO.File]::WriteAllText($envTunel, $texto, $utf8)

Write-Output "Listo: app y panel apuntan a $Url"
Write-Output 'Sube el cambio (commit + push) para que tus compañeros lo reciban con git pull.'
