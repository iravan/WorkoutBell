plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Read version from pubspec.yaml
val pubspecVersion = file("../../pubspec.yaml").readText()
    .let { text ->
        val versionMatch = Regex("version:\\s*(.+)").find(text)
        versionMatch?.groupValues?.get(1)?.trim() ?: "1.0.0+1"
    }
val (appVersionName, appVersionCode) = pubspecVersion.split("+").let {
    Pair(it[0], if (it.size > 1) it[1].toInt() else 1)
}

android {
    namespace = "com.codestopapp.workoutBell"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.codestopapp.workoutBell"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Version from pubspec.yaml: 1.0.0+1
        // versionCode is the build number (1), versionName is the version (1.0.0)
        versionCode = appVersionCode
        versionName = appVersionName
        
        // 16 KB page size support for Android 15+ (required starting November 1, 2025)
        // Android Gradle Plugin 8.5.1+ automatically handles 16 KB alignment for native libraries
        // The android:pageSizeCompat attribute is set in AndroidManifest.xml
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
