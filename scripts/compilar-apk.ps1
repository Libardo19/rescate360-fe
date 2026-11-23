param([string]$Configuracion = 'config/demo.json')

$ErrorActionPreference = 'Stop'
$r360Repo = Split-Path -Parent $PSScriptRoot
Push-Location $r360Repo
try {
    $r360Config = Get-Content -LiteralPath $Configuracion -Raw | ConvertFrom-Json
    $r360Url = [Uri]$r360Config.API_BASE_URL
    if (-not $r360Url.IsAbsoluteUri -or $r360Url.Scheme -ne 'https' -or $r360Url.IsLoopback -or $r360Url.UserInfo) {
        throw 'El APK compartido necesita API_BASE_URL con HTTPS publico. Revisa el archivo de configuracion.'
    }
    $r360Salud = Invoke-RestMethod -Uri ($r360Url.AbsoluteUri.TrimEnd('/') + '/health/ready') -TimeoutSec 20
    if ($r360Salud.status -ne 'ok') { throw 'El API no tiene conexion lista con PostgreSQL y Redis.' }
    & flutter build apk --release --obfuscate --split-debug-info=build/symbols/android "--dart-define-from-file=$Configuracion"
    if ($LASTEXITCODE -ne 0) { throw 'Fallo la compilacion del APK.' }
    Write-Output 'APK: build/app/outputs/flutter-apk/app-release.apk'
} finally {
    Pop-Location
}
