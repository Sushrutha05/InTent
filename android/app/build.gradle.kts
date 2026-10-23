plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Apply Google Services plugin
    id("com.google.firebase.crashlytics")
    id("com.google.firebase.appdistribution")
}

android {
    namespace = "com.example.student_dating_app"
    compileSdk = flutter.compileSdkVersion  // Use Flutter's compileSdkVersion
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.example.student_dating_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion  // Use Flutter's targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        buildConfig = true  // Enable BuildConfig generation
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // Update with your signing config if necessary
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

}

// Ensure intermediate dex directory expected by DexMergingTask exists under Gradle 9.1 strict validation
gradle.taskGraph.whenReady {
    listOf("debug", "release", "profile").forEach { variant ->
        layout.buildDirectory.dir("intermediates/external_file_lib_dex_archives/$variant/desugar${variant.replaceFirstChar { it.uppercase() }}FileDependencies").get().asFile.mkdirs()
    }
}

flutter {
    source = "../.."  // Correct path to your Flutter project
}

dependencies {
    // Use Firebase BOM to handle versions automatically
    implementation(platform("com.google.firebase:firebase-bom:33.1.1"))

    // Firebase dependencies
    implementation("com.google.firebase:firebase-messaging") // Firebase Messaging
    implementation("com.google.firebase:firebase-crashlytics") // Firebase Crashlytics
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
