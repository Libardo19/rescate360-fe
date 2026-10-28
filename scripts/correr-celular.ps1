# Corre la app en el celular físico (conectado por USB, en la MISMA Wi-Fi que esta PC)
# apuntando al backend de esta PC. Detecta la IP sola.
#   .\scripts\correr-celular.ps1               # elige el celular conectado
#   .\scripts\correr-celular.ps1 -Ip 192.168.1.35
# Requisitos: backend arriba (docker compose up -d en rescate360-be) y el puerto 8000
# abierto en el firewall (scripts\abrir-puerto-api.ps1, una vez, como administrador).
param([string]$Ip, [string]$Dispositivo)

$ErrorActionPreference = 'Stop'

if (-not $Ip) {
    # La IPv4 de la interfaz que tiene la ruta por defecto (la Wi-Fi o el cable de la casa)
    $ruta = Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Sort-Object RouteMetric | Select-Object -First 1
    $Ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $ruta.InterfaceIndex).IPAddress | Select-Object -First 1
}
$api = "http://${Ip}:8000"
Write-Output "API para el celular: $api"

try {
    $salud = Invoke-RestMethod -Uri "$api/health" -TimeoutSec 5
    if ($salud.status -ne 'ok') { throw }
} catch {
    throw "El backend no responde en $api. Levántalo con 'docker compose up -d' en rescate360-be."
}

$regla = Get-NetFirewallRule -DisplayName 'RESCATE360 API (puerto 8000, red local)' -ErrorAction SilentlyContinue
if (-not $regla) {
    Write-Warning 'El puerto 8000 no está abierto en el firewall: el celular no llegará al API. Ejecuta scripts\abrir-puerto-api.ps1 como administrador.'
}

$repo = Split-Path -Parent $PSScriptRoot
Push-Location $repo
try {
    $argumentos = @('run', "--dart-define=API_BASE_URL=$api")
    if ($Dispositivo) { $argumentos += @('-d', $Dispositivo) }
    & flutter @argumentos
} finally {
    Pop-Location
}
