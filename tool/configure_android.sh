#!/usr/bin/env bash
# Configura il progetto Android generato da `flutter create`:
# - imposta l'applicationId / namespace definitivo
# - imposta il nome visualizzato dell'app
#
# Va eseguito DOPO `flutter create --platforms=android .`
set -euo pipefail

APP_ID="com.ianes.battlehymn"
DEFAULT="com.example.battle_hymn"

# Sostituisci il package di default ovunque compaia nei file android.
if grep -rlZ "$DEFAULT" android >/dev/null 2>&1; then
  grep -rlZ "$DEFAULT" android | xargs -0 -r sed -i "s/${DEFAULT//./\\.}/${APP_ID}/g"
fi

# Nome dell'app mostrato sotto l'icona.
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  sed -i 's/android:label="[^"]*"/android:label="Battle Hymn"/' "$MANIFEST"
fi

echo "Android configurato con applicationId=$APP_ID"
