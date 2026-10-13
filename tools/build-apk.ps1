# Rebuilds Kachuful.apk on Shyamal's laptop and copies it to Downloads.
# Only needed for native changes (loader, icon, app name). Normal app changes just need a
# push to main: the phone downloads them on next launch.
# Before building a new APK: bump versionCode/versionName in
# C:\Users\bhatt\android-build\kachuful\android\app\build.gradle,
# then publish it with: gh release create v<version> "$env:USERPROFILE\Downloads\Kachuful.apk"
$ErrorActionPreference = 'Stop'
$b = "C:\Users\bhatt\android-build"
$repo = Split-Path $PSScriptRoot -Parent
$cap = "$b\kachuful"

Remove-Item "$cap\www\*" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$cap\www" | Out-Null
Copy-Item "$repo\index.html" "$cap\www\app.html"
Copy-Item "$repo\android\loader.html" "$cap\www\index.html"
Copy-Item "$repo\manifest.json", "$repo\kachuful-logo.png", "$repo\icon-192.png", "$repo\icon-512.png", "$repo\icon-maskable-512.png" "$cap\www"
# launcher icons (made by tools/make-icons.ps1)
Copy-Item "$repo\android\res\*" "$cap\android\app\src\main\res\" -Recurse -Force

$env:JAVA_HOME = "$b\jdk-21.0.12.1+1"; $env:ANDROID_HOME = "$b\sdk"; $env:Path = "$env:JAVA_HOME\bin;$env:Path"
Push-Location $cap; npx cap sync android; Pop-Location
Push-Location "$cap\android"; & .\gradlew.bat assembleDebug --no-daemon -q --console=plain; $code = $LASTEXITCODE; Pop-Location
if ($code -ne 0) { throw "Gradle build failed ($code)" }

Copy-Item "$cap\android\app\build\outputs\apk\debug\app-debug.apk" "$env:USERPROFILE\Downloads\Kachuful.apk" -Force
"APK ready: $env:USERPROFILE\Downloads\Kachuful.apk"
