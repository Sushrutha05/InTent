plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Apply Google Services plugin
}

android {
    namespace = "com.example.student_dating_app"
    compileSdk = flutter.compileSdkVersion  // Use Flutter's compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.student_dating_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion  // Use Flutter's targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        buildConfig = true  // Enable BuildConfig generation
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // Update with your signing config if necessary
        }
    }

}

flutter {
    source = "../.."  // Correct path to your Flutter project
}

dependencies {
    // Use Firebase BOM to handle versions automatically
    implementation(platform("com.google.firebase:firebase-bom:32.0.0"))  // Latest Firebase BOM version

    // Firebase dependencies
    implementation("com.google.firebase:firebase-auth")  // Firebase Authentication
    implementation("com.google.firebase:firebase-firestore")  // Firebase Firestore
    implementation("com.google.firebase:firebase-database")  // Firebase Realtime Database
    implementation("com.google.firebase:firebase-messaging") // Firebase Messaging
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
