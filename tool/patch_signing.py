#!/usr/bin/env python3
"""Abilita la firma di release nel progetto Android generato da `flutter create`.

Va eseguito DOPO `flutter create --platforms=android .` e DOPO aver scritto
`android/key.properties` + il keystore. Modifica `android/app/build.gradle.kts`
per:
  - caricare `key.properties`;
  - definire un `signingConfigs.release` che usa quel keystore;
  - far usare al buildType `release` quella firma (invece di quella di debug).

Se `key.properties` non esiste (es. build locale senza segreti) lo script non
fa nulla, così il workflow dell'APK continua a funzionare con la firma di debug.
"""
import pathlib
import re
import sys

GRADLE = pathlib.Path("android/app/build.gradle.kts")
KEY_PROPS = pathlib.Path("android/key.properties")

# Blocco da inserire prima di `android {` per leggere le credenziali del keystore.
LOAD_BLOCK = """import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

"""

# Blocco signingConfigs da inserire all'inizio del blocco `android {`.
SIGNING_BLOCK = """    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

"""


def main() -> int:
    if not KEY_PROPS.exists():
        print("key.properties assente: salto la firma di release (resta debug).")
        return 0
    if not GRADLE.exists():
        print(f"ERRORE: {GRADLE} non trovato. Esegui prima `flutter create`.",
              file=sys.stderr)
        return 1

    src = GRADLE.read_text()

    if "signingConfigs" in src and 'create("release")' in src:
        print("Firma di release già configurata: nessuna modifica.")
        return 0

    # 1) import + caricamento key.properties prima di `android {`.
    if "keystorePropertiesFile" not in src:
        idx = src.index("android {")
        src = src[:idx] + LOAD_BLOCK + src[idx:]

    # 2) signingConfigs subito dopo l'apertura di `android {`.
    src = src.replace("android {\n", "android {\n" + SIGNING_BLOCK, 1)

    # 3) il buildType release usa la firma release.
    src = re.sub(
        r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
        'signingConfig = signingConfigs.getByName("release")',
        src,
    )

    GRADLE.write_text(src)
    print("build.gradle.kts aggiornato: firma di release abilitata.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
