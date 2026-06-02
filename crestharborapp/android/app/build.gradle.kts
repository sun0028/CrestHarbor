plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.crestharborapp"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
      }
     }

    signingConfigs {
        getByName("debug") {
           
        }
    }

    defaultConfig {
        applicationId = "com.example.crestharborapp"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            
            signingConfig = signingConfigs.getByName("debug")
            
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}



flutter {
    source = "../.."
}
