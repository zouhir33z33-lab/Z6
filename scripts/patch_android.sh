#!/usr/bin/env bash
# Applique la configuration Android après `flutter create` (permissions, nom).
set -e
M=android/app/src/main/AndroidManifest.xml
if ! grep -q "MANAGE_EXTERNAL_STORAGE" "$M"; then
  sed -i 's|<application|<uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>\n    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>\n    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>\n    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>\n    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>\n    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>\n    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>\n    <application|' "$M"
fi
sed -i 's|android:label="[^"]*"|android:label="EPS Assistant"|' "$M"

# Canal natif de luminosité (bouton « شمس » du mode terrain)
KDIR=android/app/src/main/kotlin/dz/eps/assistant/eps_assistant
mkdir -p "$KDIR"
cp scripts/MainActivity.kt "$KDIR/MainActivity.kt"

# Certaines bibliothèques AndroidX récentes exigent compileSdk 36 alors que des plugins
# (file_picker, etc.) sont compilés avec 34/35 : on force compileSdk 36 pour tous les modules.
if [ -f android/build.gradle.kts ]; then
  if ! grep -q "EPS_FORCE_COMPILE_SDK" android/build.gradle.kts; then
    cat >> android/build.gradle.kts <<'KTS'

// EPS_FORCE_COMPILE_SDK
subprojects {
    val forceSdk = {
        val ext = extensions.findByName("android")
        if (ext is com.android.build.gradle.BaseExtension) {
            ext.compileSdkVersion(36)
        }
    }
    if (state.executed) forceSdk() else afterEvaluate { forceSdk() }
}
KTS
  fi
elif [ -f android/build.gradle ]; then
  if ! grep -q "EPS_FORCE_COMPILE_SDK" android/build.gradle; then
    cat >> android/build.gradle <<'GRADLE'

// EPS_FORCE_COMPILE_SDK
subprojects {
    def forceSdk = { p ->
        if (p.hasProperty('android')) {
            p.android.compileSdkVersion 36
        }
    }
    if (state.executed) { forceSdk(it) } else { afterEvaluate { forceSdk(it) } }
}
GRADLE
  fi
fi
