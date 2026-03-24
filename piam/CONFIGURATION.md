# ⚙️ Configuration - Application PIAM

## Prérequis système

### Environnement de développement
- **OS** : Windows 10/11, macOS 12+, Ubuntu 20.04+
- **RAM** : Minimum 8GB, recommandé 16GB
- **Stockage** : 5GB d'espace libre
- **CPU** : Intel i5/AMD Ryzen 5 ou supérieur

### Logiciels requis
- **Flutter SDK** : 3.35.3 ou supérieur
- **Dart SDK** : 3.9.2 ou supérieur
- **Android Studio** : 2022.3+ (avec Android SDK)
- **VS Code** : Avec extensions Flutter/Dart
- **Git** : 2.30+ pour le contrôle de version

## Installation de Flutter

### Windows
```powershell
# Téléchargement
git clone https://github.com/flutter/flutter.git -b stable

# Ajout au PATH
# C:\flutter\bin

# Vérification
flutter doctor
```

### macOS
```bash
# Via Homebrew
brew install --cask flutter

# Ou manuel
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Vérification
flutter doctor
```

### Linux
```bash
# Installation des dépendances
sudo apt update
sudo apt install curl git unzip xz-utils zip libglu1-mesa

# Téléchargement Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Vérification
flutter doctor
```

## Configuration Android

### Android Studio
1. **Téléchargement** : https://developer.android.com/studio
2. **Installation** : Suivre l'assistant d'installation
3. **SDK Components** :
   - Android SDK
   - Android SDK Platform
   - Android SDK Build-Tools
   - Android Emulator

### Variables d'environnement
```bash
# Windows
set ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
set PATH=%PATH%;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools

# macOS/Linux
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### Création d'un émulateur
```bash
# Liste des devices disponibles
flutter emulators

# Création d'un nouvel émulateur
flutter emulators --create --name "Pixel_6_API_33"

# Lancement
flutter emulators --launch Pixel_6_API_33
```

## Configuration iOS (macOS uniquement)

### Xcode
1. **App Store** : Télécharger Xcode
2. **Command Line Tools** :
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### iOS Simulator
```bash
# Liste des simulateurs
flutter devices

# Lancement du simulateur
open -a Simulator
```

## Configuration du projet

### Clonage et setup
```bash
# Clonage du repository
git clone <repository-url>
cd piam-mobile/piam

# Installation des dépendances
flutter pub get

# Vérification des dépendances
flutter doctor -v
```

### Configuration des assets
```
assets/
├── images/
│   ├── logo_piam.png
│   └── icons/
│       ├── check.png
│       └── warning.png
└── fonts/
    ├── Roboto-Regular.ttf
    └── Roboto-Bold.ttf
```

### Configuration des icônes
```yaml
# pubspec.yaml
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/logo_piam.png"
```

## Variables d'environnement

### Fichier .env
```env
# Configuration API
API_BASE_URL=https://api.piam.org
API_TIMEOUT=30000

# Base de données
DB_NAME=piam.db
DB_VERSION=1

# Authentification
JWT_SECRET=your-secret-key
TOKEN_EXPIRY=3600

# Géolocalisation
GPS_ACCURACY=high
GPS_TIMEOUT=10000

# Synchronisation
SYNC_INTERVAL=300000
SYNC_RETRY_ATTEMPTS=3
```

### Configuration Flutter
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.piam.org',
  );

  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );

  static const String dbName = String.fromEnvironment(
    'DB_NAME',
    defaultValue: 'piam.db',
  );
}
```

## Permissions et sécurité

### Android Manifest
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions Internet -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Permissions Géolocalisation -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <!-- Permissions Stockage -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <!-- Permissions Caméra -->
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="PIAM"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenWidth|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### iOS Info.plist
```xml
<!-- ios/Runner/Info.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Permissions Géolocalisation -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Cette application utilise votre localisation pour géolocaliser les chantiers.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Cette application utilise votre localisation en continu pour le suivi des contrôles.</string>

    <!-- Permissions Caméra -->
    <key>NSCameraUsageDescription</key>
    <string>Cette application utilise la caméra pour prendre des photos des travaux.</string>

    <!-- Permissions Photos -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Cette application accède à votre bibliothèque photos pour sauvegarder les images.</string>

    <!-- Permissions Stockage -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Cette application sauvegarde les photos dans votre bibliothèque.</string>

    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>piam</string>
    <key>CFBundlePackageType</key>
    <string>APK</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

## Configuration de build

### Build Android
```gradle
// android/app/build.gradle
android {
    namespace 'org.piam.mobile'
    compileSdk flutter.compileSdkVersion

    defaultConfig {
        applicationId "org.piam.mobile"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### ProGuard Rules
```proguard
# android/app/proguard-rules.pro
-keep class org.piam.** { *; }
-keep class * extends androidx.room.Entity { *; }
-dontwarn org.piam.**
-dontwarn androidx.**
```

## Outils de développement

### Extensions VS Code recommandées
```json
{
    "recommendations": [
        "Dart-Code.dart-code",
        "Dart-Code.flutter",
        "ms-vscode.vscode-json",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-yaml",
        "redhat.vscode-yaml",
        "ms-vscode-remote.remote-containers"
    ]
}
```

### Configuration VS Code
```json
// .vscode/settings.json
{
    "dart.flutterSdkPath": "C:\\flutter",
    "dart.sdkPath": "C:\\flutter\\bin\\cache\\dart-sdk",
    "flutter.hotReloadOnSave": "all",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll": "explicit",
        "source.organizeImports": "explicit"
    },
    "dart.analysisExcludedFolders": [
        ".dart_tool",
        "build"
    ]
}
```

### Lancement des tâches
```json
// .vscode/tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Flutter: Get Dependencies",
            "type": "flutter",
            "command": "flutter",
            "args": ["pub", "get"],
            "group": "build"
        },
        {
            "label": "Flutter: Analyze",
            "type": "flutter",
            "command": "flutter",
            "args": ["analyze"],
            "group": "test"
        },
        {
            "label": "Flutter: Run Tests",
            "type": "flutter",
            "command": "flutter",
            "args": ["test"],
            "group": "test"
        }
    ]
}
```

## Déploiement

### Build de production
```bash
# Android APK
flutter build apk --release --split-per-abi

# Android App Bundle
flutter build appbundle --release

# iOS (sur macOS)
flutter build ios --release
```

### Signature Android
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file('path/to/keystore.jks')
            storePassword System.getenv('STORE_PASSWORD')
            keyAlias System.getenv('KEY_ALIAS')
            keyPassword System.getenv('KEY_PASSWORD')
        }
    }
}
```

### Variables d'environnement CI/CD
```bash
# Variables GitHub Actions
STORE_PASSWORD=your_store_password
KEY_ALIAS=your_key_alias
KEY_PASSWORD=your_key_password
```

## Tests et qualité

### Configuration des tests
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.6
```

### Scripts de test
```json
// package.json (pour npm scripts)
{
    "scripts": {
        "test": "flutter test",
        "test:coverage": "flutter test --coverage",
        "analyze": "flutter analyze",
        "format": "flutter format .",
        "build:android": "flutter build apk --release",
        "build:ios": "flutter build ios --release"
    }
}
```

## Monitoring et logging

### Configuration Firebase
```dart
// lib/config/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }
}
```

### Logging personnalisé
```dart
// lib/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
```

## Dépannage

### Problèmes courants

#### Flutter doctor erreurs
```bash
# Mise à jour Flutter
flutter upgrade

# Nettoyage cache
flutter clean
flutter pub cache repair

# Vérification licences Android
flutter doctor --android-licenses
```

#### Émulateur Android lent
```bash
# Configuration émulateur
emulator -avd <avd_name> -gpu host -accel on

# Cold boot
emulator -avd <avd_name> -no-snapshot-load
```

#### Erreurs de build
```bash
# Nettoyage complet
flutter clean
rm -rf pubspec.lock
flutter pub get
flutter pub upgrade

# Build cache
flutter pub run build_runner clean
flutter pub run build_runner build
```

#### Problèmes de permissions
```bash
# Android
adb shell pm grant org.piam.mobile android.permission.ACCESS_FINE_LOCATION
adb shell pm grant org.piam.mobile android.permission.CAMERA

# iOS : Reset permissions via Réglages > Confidentialité
```

---

**Configuration - Version 1.0**
*Application PIAM - Mars 2026*