import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.robocell.app"
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
        applicationId = "com.robocell.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                val keyAliasProp = keystoreProperties.getProperty("keyAlias")
                val keyPasswordProp = keystoreProperties.getProperty("keyPassword")
                val storeFileProp = keystoreProperties.getProperty("storeFile")
                val storePasswordProp = keystoreProperties.getProperty("storePassword")

                val resolvedStoreFile = storeFileProp?.let {
                    file(it).let { f -> if (f.exists()) f else rootProject.file(it) }
                }

                if (resolvedStoreFile != null && resolvedStoreFile.exists() &&
                    !keyAliasProp.isNullOrEmpty() && !keyPasswordProp.isNullOrEmpty() &&
                    !storePasswordProp.isNullOrEmpty()) {
                    keyAlias = keyAliasProp
                    keyPassword = keyPasswordProp
                    storeFile = resolvedStoreFile
                    storePassword = storePasswordProp
                } else {
                    throw GradleException("Release build failure: android/key.properties or upload keystore file is invalid.")
                }
            } else {
                throw GradleException("Release build failure: android/key.properties file not found.")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
