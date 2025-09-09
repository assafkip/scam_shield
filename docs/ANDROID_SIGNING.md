# Android Release Signing Setup

## Prerequisites
- Android SDK installed with build tools
- Java JDK 11+ for keystore generation
- Flutter configured for release builds

## Step 1: Generate Release Keystore

**⚠️ SECURITY: Store keystore securely and never commit to version control**

```bash
# Navigate to project root
cd /path/to/scamshield

# Generate release keystore (replace with actual values)
keytool -genkey -v -keystore android/app/release-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias scamshield-release

# You will be prompted for:
# - Keystore password (store securely)
# - Key password (store securely) 
# - Your name and organization details
```

**Example Values for ScamShield:**
- First and last name: ScamShield App
- Organizational unit: Development
- Organization: ScamShield
- City/Locality: [Your City]
- State/Province: [Your State]
- Country code: [Your Country Code]

## Step 2: Configure Gradle Properties

Create `android/key.properties` (LOCAL ONLY - DO NOT COMMIT):

```properties
storePassword=[KEYSTORE_PASSWORD]
keyPassword=[KEY_PASSWORD] 
keyAlias=scamshield-release
storeFile=release-keystore.jks
```

## Step 3: Update app/build.gradle.kts

The following configuration will be added to handle release signing:

```kotlin
// Load signing configuration
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing configuration
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

## Step 4: Update Application ID

Change from `com.example.scamshield` to production ID:

```kotlin
defaultConfig {
    applicationId = "com.scamshield.app"  // Update this
    // ... rest of config
}
```

## Step 5: Build Release AAB

```bash
# Clean and build release
flutter clean
flutter pub get

# Build release App Bundle
flutter build appbundle --release

# Output will be at:
# build/app/outputs/bundle/release/app-release.aab
```

## Step 6: Verify Build

```bash
# Check AAB details
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=scamshield.apks \
  --mode=universal

# Extract and install for testing
unzip scamshield.apks universal.apk
adb install universal.apk
```

## Security Checklist

### Keystore Security
- [ ] Keystore file backed up securely offline
- [ ] Passwords stored in secure password manager
- [ ] `key.properties` added to `.gitignore`
- [ ] Keystore file excluded from version control

### Build Configuration
- [ ] Release signing configured correctly
- [ ] ProGuard/R8 obfuscation enabled
- [ ] Debug signatures removed from release
- [ ] Application ID updated to production value

### Testing
- [ ] Release AAB builds successfully
- [ ] Signed APK installs and runs correctly
- [ ] No debug features exposed in release build
- [ ] App size optimized (under 50MB installed)

## Troubleshooting

### Common Issues

**Build fails with signing errors:**
- Verify `key.properties` path and values
- Ensure keystore file exists at specified path
- Check password accuracy

**AAB too large:**
- Enable R8 shrinking and obfuscation
- Remove unused assets and dependencies
- Check for duplicate resources

**Installation fails:**
- Verify signing configuration
- Check target SDK compatibility
- Ensure proper application ID format

### File Locations

```
android/
├── app/
│   ├── build.gradle.kts (updated with signing)
│   ├── proguard-rules.pro (R8 rules)
│   └── release-keystore.jks (DO NOT COMMIT)
├── key.properties (DO NOT COMMIT)
└── .gitignore (includes key.properties)
```

## Store Upload

1. **Play Console**: Upload `app-release.aab` to internal testing
2. **Verify**: Install from Play Console to test distribution
3. **Monitor**: Check for any signing or compatibility issues
4. **Promote**: Move to production after successful testing