import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
            load(reader)
        }
    }
}

// Load key.properties (check both android/ and root directory)
val keystorePropertiesFile = sequenceOf(
    rootProject.file("key.properties"),
    rootProject.file("../key.properties")
).firstOrNull { it.exists() }

val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile != null && keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { stream ->
            load(stream)
        }
    }
}

val storeFilePath = keystoreProperties.getProperty("storeFile")
val keystoreFile = if (storeFilePath != null) {
    val f = file(storeFilePath)
    if (f.exists()) f else {
        val f2 = keystorePropertiesFile?.parentFile?.resolve(storeFilePath)
        if (f2 != null && f2.exists()) f2 else null
    }
} else null

android {
//    namespace = "com.myfoozzybusiness"
    namespace = "com.tpipay.feetrack_student_parent"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        if (keystoreFile != null && keystoreFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    defaultConfig {
//        applicationId = "com.myfoozzybusiness"
        applicationId = "com.tpipay.feetrack_student_parent"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            val releaseSigningConfig = signingConfigs.findByName("release")
            signingConfig = releaseSigningConfig ?: signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("com.android.installreferrer:installreferrer:2.2")
}

flutter {
    source = "../.."
}
