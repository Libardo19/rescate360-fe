# Permite que el celular (en la misma Wi-Fi) llegue al API en el puerto 8000 de esta PC.
# Ejecutar UNA vez en PowerShell como ADMINISTRADOR:
#   .\scripts\abrir-puerto-api.ps1
# Solo acepta conexiones de tu red local (LocalSubnet), no de internet.
$ErrorActionPreference = 'Stop'

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { throw 'Abre PowerShell como administrador y vuelve a ejecutar este script.' }

$nombre = 'RESCATE360 API (puerto 8000, red local)'
if (Get-NetFirewallRule -DisplayName $nombre -ErrorAction SilentlyContinue) {
    Write-Output "La regla '$nombre' ya existe."
} else {
    New-NetFirewallRule -DisplayName $nombre -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000 `
        -RemoteAddress LocalSubnet -Profile Any | Out-Null
    Write-Output "Regla creada: '$nombre'."
}
