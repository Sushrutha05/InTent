plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.student_dating_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "26.3.11579264"

    buildFeatures {
        buildConfig = true // Enable BuildConfig generation
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.student_dating_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Apply the Google services plugin
/*apply(plugin = "com.google.gms.google-services")

dependencies {
    // Firebase SDK for Flutter (you can add more Firebase packages depending on the features you need)
    implementation("com.google.firebase:firebase-auth:21.0.1")  // For Firebase Authentication

    // Other Firebase dependencies if needed
    // implementation 'com.google.firebase:firebase-firestore:24.0.3'
    // implementation 'com.google.firebase:firebase-database:20.0.3'
}
*/



