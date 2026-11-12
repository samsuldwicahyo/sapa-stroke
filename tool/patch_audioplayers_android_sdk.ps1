$ErrorActionPreference = 'Stop'

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$packageConfigPath = Join-Path $projectRoot '.dart_tool\package_config.json'

if (-not (Test-Path $packageConfigPath)) {
    throw "package_config.json tidak ditemukan. Jalankan 'flutter pub get' terlebih dahulu."
}

$packageConfig = Get-Content $packageConfigPath -Raw | ConvertFrom-Json
$audioPlayersAndroid = $packageConfig.packages | Where-Object { $_.name -eq 'audioplayers_android' } | Select-Object -First 1

if (-not $audioPlayersAndroid) {
    throw "Paket audioplayers_android tidak ditemukan di package_config.json."
}

$rootUri = [System.Uri]$audioPlayersAndroid.rootUri
$pluginRoot = $rootUri.LocalPath
$buildGradlePath = Join-Path $pluginRoot 'android\build.gradle'

if (-not (Test-Path $buildGradlePath)) {
    throw "File build.gradle plugin tidak ditemukan di: $buildGradlePath"
}

$content = Get-Content $buildGradlePath -Raw
$updated = $content `
    -replace 'compileSdk\s*=\s*35', 'compileSdk = 34' `
    -replace 'compileSdk\s+35', 'compileSdk 34'

if ($updated -eq $content) {
    Write-Output "Tidak ada perubahan. Plugin audioplayers_android sudah tidak memakai compileSdk 35."
    exit 0
}

Set-Content -Path $buildGradlePath -Value $updated -NoNewline
Write-Output "Berhasil patch audioplayers_android ke compileSdk 34 di: $buildGradlePath"
