plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.projekt_izynierski"
    compileSdk = 36 // <--- Изменили с flutter.compileSdkVersion на 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.projekt_izynierski"
        minSdk = flutter.minSdkVersion
        targetSdk = 36 // <--- Изменили с flutter.targetSdkVersion на 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndkVersion = "28.2.13676358"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
