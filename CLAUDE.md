# Kachuful scorekeeper

Single-file web app (`index.html`, vanilla JS, no build step) served from GitHub Pages at
https://imshyamalbhatt.github.io/kachuful/ and wrapped as an Android APK.

## How changes reach the phone
- The APK ships `android/loader.html` as its start page. At every launch it fetches the live
  `index.html` from GitHub Pages, so **a push to main updates the app**. No new APK is needed.
- The loader only accepts a page containing `data-app="kachuful"` that ends in `</html>`.
  Keep both. The app writes `kachuful.boot = ok` after its first render; if that never happens the
  loader marks the download bad and falls back to the copy bundled in the APK.
- Rebuild the APK only for native changes (loader, icon, app name): `tools/build-apk.ps1`, then bump
  versionCode/versionName in `C:\Users\bhatt\android-build\kachuful\android\app\build.gradle` and
  `gh release create v<x> "$env:USERPROFILE\Downloads\Kachuful.apk"`.
- Signing uses `~/.android/debug.keystore` (same key as Pocket Money). Never change it or updates won't install.

## Workflow
- Preview locally: `node tools/serve.js` → http://localhost:5180 (Shyamal opens it in VS Code's Simple Browser).
  He doesn't want claude.ai artifacts for this project.
- Show changes on localhost first and push only after he approves.
- Icons: `tools/make-icons.ps1` regenerates every icon from `design/logo-source.png`.
- Saved state lives in localStorage under `kachuful.v1` (`{setup, game}`). Don't rename keys
  without migrating, or people lose a game in progress.

## Game rules encoded
- Trump order by round: Kali ♠, Chukat ♦, Fuli ♣, Laal ♥.
- Dealer rotates clockwise from the chosen first dealer; bidding starts left of the dealer.
- Scoring is a setup choice (hit: 10+bid / bid×10 / flat 10; miss: 0 / −10 / minus the same).
