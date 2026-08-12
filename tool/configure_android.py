from pathlib import Path
import re
import shutil

ROOT = Path(__file__).resolve().parents[1]
ANDROID = ROOT / "android"
APP = ANDROID / "app"

manifest = APP / "src" / "main" / "AndroidManifest.xml"
if manifest.exists():
    text = manifest.read_text(encoding="utf-8")

    # Le Manifest Merger a besoin du namespace "tools" pour supprimer une
    # permission éventuellement ajoutée par une dépendance.
    manifest_tag = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
    manifest_tag_tools = (
        '<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n'
        '    xmlns:tools="http://schemas.android.com/tools">'
    )
    if 'xmlns:tools=' not in text:
        text = text.replace(manifest_tag, manifest_tag_tools, 1)

    # Nom public de l'application.
    text = text.replace('android:label="droneatlas"', 'android:label="Drone Atlas Academy"')
    text = text.replace('android:label="Droneatlas"', 'android:label="Drone Atlas Academy"')
    text = text.replace('android:label="DroneAtlas"', 'android:label="Drone Atlas Academy"')

    # Permissions réellement nécessaires à l'application.
    permissions = [
        'android.permission.INTERNET',
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.ACCESS_FINE_LOCATION',
    ]

    # Insérer les permissions juste après la balise <manifest ...>.
    manifest_close = manifest_tag_tools if 'xmlns:tools=' in text else manifest_tag
    insertion_lines = []
    for permission in permissions:
        marker = f'<uses-permission android:name="{permission}" />'
        if marker not in text:
            insertion_lines.append(f'    {marker}')

    if insertion_lines:
        text = text.replace(
            manifest_close,
            manifest_close + '\n' + '\n'.join(insertion_lines),
            1,
        )

    # Google Play détectait FOREGROUND_SERVICE_DATA_SYNC via une dépendance.
    # Drone Atlas Academy n'utilise pas de service foreground de type dataSync.
    # Cette règle demande au Manifest Merger de retirer uniquement cette
    # permission du manifeste final.
    data_sync_permission = 'android.permission.FOREGROUND_SERVICE_DATA_SYNC'
    remove_rule = (
        '    <uses-permission\n'
        f'        android:name="{data_sync_permission}"\n'
        '        tools:node="remove" />'
    )

    if f'android:name="{data_sync_permission}"' not in text:
        # Ajouter la règle après les permissions principales.
        anchor = '    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />'
        if anchor in text:
            text = text.replace(anchor, anchor + '\n' + remove_rule, 1)
        else:
            text = text.replace(manifest_close, manifest_close + '\n' + remove_rule, 1)

    manifest.write_text(text, encoding="utf-8")

icon_root = ROOT / "tool" / "icons"
res_root = APP / "src" / "main" / "res"
for source_dir in icon_root.glob("mipmap-*"):
    source = source_dir / "ic_launcher.png"
    if source.exists():
        target_dir = res_root / source_dir.name
        target_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target_dir / "ic_launcher.png")

# Configuration nécessaire à flutter_local_notifications 22.x.
gradle = APP / "build.gradle.kts"
if gradle.exists():
    text = gradle.read_text(encoding="utf-8")
    text = re.sub(r'compileSdk\s*=\s*flutter\.compileSdkVersion', 'compileSdk = 36', text)
    text = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24', text)
    text = re.sub(
        r'sourceCompatibility\s*=\s*JavaVersion\.VERSION_\d+',
        'sourceCompatibility = JavaVersion.VERSION_17',
        text,
    )
    text = re.sub(
        r'targetCompatibility\s*=\s*JavaVersion\.VERSION_\d+',
        'targetCompatibility = JavaVersion.VERSION_17',
        text,
    )
    text = re.sub(
        r'jvmTarget\s*=\s*JavaVersion\.VERSION_\d+\.toString\(\)',
        'jvmTarget = JavaVersion.VERSION_17.toString()',
        text,
    )
    if 'isCoreLibraryDesugaringEnabled = true' not in text:
        text = text.replace(
            'compileOptions {',
            'compileOptions {\n        isCoreLibraryDesugaringEnabled = true',
            1,
        )
    if 'multiDexEnabled = true' not in text:
        text = text.replace(
            'defaultConfig {',
            'defaultConfig {\n        multiDexEnabled = true',
            1,
        )
    # Signature Google Play facultative. Le workflow crée android/key.properties
    # et android/app/upload-keystore.jks lorsque les secrets GitHub sont présents.
    if 'import java.io.FileInputStream' not in text:
        text = 'import java.io.FileInputStream\nimport java.util.Properties\n\n' + text

    keystore_block = """val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

"""
    if 'val keystoreProperties = Properties()' not in text:
        text = text.replace('}\n\nandroid {', '}\n\n' + keystore_block + 'android {', 1)

    signing_block = """    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

"""
    if 'create("release")' not in text:
        text = text.replace('    buildTypes {', signing_block + '    buildTypes {', 1)

    release_marker = "buildTypes {\n        release {"
    release_signing = (
        'signingConfig = if (keystorePropertiesFile.exists()) '
        'signingConfigs.getByName("release") else signingConfigs.getByName("debug")'
    )
    debug_signing = 'signingConfig = signingConfigs.getByName("debug")'
    if debug_signing in text:
        text = text.replace(debug_signing, release_signing)
    elif release_marker in text and release_signing not in text:
        text = text.replace(
            release_marker,
            release_marker + '\n            ' + release_signing,
        )
    dependencies = '''

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}
'''
    if 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' not in text:
        text = text.rstrip() + dependencies
    gradle.write_text(text, encoding="utf-8")

settings = ANDROID / "settings.gradle.kts"
if settings.exists():
    text = settings.read_text(encoding="utf-8")
    text = re.sub(
        r'id\("com\.android\.application"\) version "[^"]+"',
        'id("com.android.application") version "8.13.2"',
        text,
    )
    text = re.sub(
        r'id\("org\.jetbrains\.kotlin\.android"\) version "[^"]+"',
        'id("org.jetbrains.kotlin.android") version "2.1.20"',
        text,
    )
    settings.write_text(text, encoding="utf-8")

wrapper = ANDROID / "gradle" / "wrapper" / "gradle-wrapper.properties"
if wrapper.exists():
    text = wrapper.read_text(encoding="utf-8")
    text = re.sub(
        r'distributionUrl=.*gradle-[^-]+-(?:all|bin)\.zip',
        'distributionUrl=https\\://services.gradle.org/distributions/gradle-8.14.3-bin.zip',
        text,
    )
    if re.search(r'^networkTimeout=.*$', text, flags=re.MULTILINE):
        text = re.sub(
            r'^networkTimeout=.*$',
            'networkTimeout=60000',
            text,
            flags=re.MULTILINE,
        )
    else:
        text += '\nnetworkTimeout=60000\n'

    gradle_sha = 'bd71102213493060956ec229d946beee57158dbd89d0e62b91bca0fa2c5f3531'
    if re.search(r'^distributionSha256Sum=.*$', text, flags=re.MULTILINE):
        text = re.sub(
            r'^distributionSha256Sum=.*$',
            f'distributionSha256Sum={gradle_sha}',
            text,
            flags=re.MULTILINE,
        )
    else:
        text += f'distributionSha256Sum={gradle_sha}\n'

    wrapper.write_text(text, encoding="utf-8")


# Les pages d'examen et l'aperçu filigrané activent FLAG_SECURE via MethodChannel.
main_activity = APP / "src" / "main" / "kotlin" / "com" / "novateur221" / "droneatlas" / "MainActivity.kt"
main_activity.parent.mkdir(parents=True, exist_ok=True)
main_activity.write_text(
    """package com.novateur221.droneatlas

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val securityChannel = \"droneatlas/security\"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            securityChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                \"enableSecure\" -> {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                \"disableSecure\" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
""",
    encoding="utf-8",
)

print("Configuration Android Drone Atlas Academy (notifications, localisation, signature Play Store et mises à jour) appliquée.")
