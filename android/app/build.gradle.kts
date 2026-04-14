plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("com.google.firebase.appdistribution")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val isReleaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true) ||
        it.contains("bundle", ignoreCase = true)
}
var hasReleaseSigning = false
val appRootDir = rootProject.projectDir.parentFile

fun resolveKeystoreFile(path: String?): File? {
    val configuredPath = path?.trim()?.takeIf { it.isNotEmpty() } ?: return null
    val rawFile = File(configuredPath)

    val candidates = buildList {
        if (rawFile.isAbsolute) {
            add(rawFile)
        }
        add(rootProject.file(configuredPath))
        add(appRootDir.resolve(configuredPath))
        add(appRootDir.resolve(rawFile.name))
    }

    return candidates.firstOrNull { it.exists() }
}

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.wecoop.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.wecoop.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

   signingConfigs {
    create("release") {
        val storeFilePath = keystoreProperties.getProperty("storeFile")
        val resolvedFile = resolveKeystoreFile(storeFilePath)

        if (resolvedFile != null && resolvedFile.exists()) {
            hasReleaseSigning = true
            storeFile = resolvedFile
            storePassword = keystoreProperties.getProperty("storePassword") ?: ""
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: ""
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
            println("✅ Firma release configurata correttamente")
        } else if (isReleaseBuildRequested) {
            throw GradleException(
                "❌ Errore: il file di firma '${storeFilePath}' non esiste o non è accessibile.",
            )
        }
    }
}




    buildTypes {
        getByName("release") {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

tasks.withType<JavaCompile> {
    sourceCompatibility = "17"
    targetCompatibility = "17"
    options.compilerArgs.add("-Xlint:-options")
}
