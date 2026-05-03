import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ Load keystore properties
val keystoreProperties = Properties()

val keystorePropertiesFile = File(rootProject.projectDir, "key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.issubi.i_card"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.issubi.i_card"

        // ✅ FORCE this (important for mobile_scanner)
        minSdk = 23

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Add signing config
    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String
            val storePasswordValue = keystoreProperties["storePassword"] as String
            val keyAliasValue = keystoreProperties["keyAlias"] as String
            val keyPasswordValue = keystoreProperties["keyPassword"] as String

            require(storeFilePath.isNotEmpty()) { "storeFile missing" }
            require(storePasswordValue.isNotEmpty()) { "storePassword missing" }

            storeFile = file(storeFilePath)
            storePassword = storePasswordValue
            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
        }
    }

    buildTypes {
        getByName("release") {
            // ❗ Use release signing instead of debug
            signingConfig = signingConfigs.getByName("release")

        isMinifyEnabled = false
        isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}