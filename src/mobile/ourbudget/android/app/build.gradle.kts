import java.net.URI
import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ourbudget.ourbudget"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ourbudget.ourbudget"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
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

val dartDefines = providers.gradleProperty("dart-defines").orElse("")
val checkReleaseEndpoints by tasks.registering {
    inputs.property("dartDefines", dartDefines)
    doLast {
        val defines = dartDefines.get().split(',').filter { it.isNotEmpty() }.associate {
            val entry = String(Base64.getDecoder().decode(it), Charsets.UTF_8)
            entry.substringBefore('=') to entry.substringAfter('=', "")
        }
        val api = runCatching { URI(defines["API_BASE_URL"].orEmpty()) }.getOrNull()
        val host = api?.host?.lowercase()?.trimEnd('.').orEmpty()
        require(api?.scheme == "https" && host.isNotEmpty() &&
            host !in setOf("localhost", "10.0.2.2", "10.0.3.2", "[::1]", "0.0.0.0") &&
            !host.startsWith("127.") && !host.endsWith(".localhost") &&
            !host.endsWith(".supabase.co") && api.rawUserInfo == null &&
            api.rawQuery == null && api.rawFragment == null && api.rawPath in listOf("", "/")) {
            "OurBudget release requires --dart-define=API_BASE_URL=<HTTPS origin of the PHP backend>."
        }
        defines["SUPABASE_URL"]?.let { value ->
            val url = runCatching { URI(value) }.getOrNull()
            require(url?.scheme == "https" && !url.host.isNullOrEmpty()) {
                "SUPABASE_URL must be an HTTPS URL."
            }
        }
        (defines["SUPABASE_PUBLISHABLE_KEY"] ?: defines["SUPABASE_ANON_KEY"])?.let { key ->
            require(key.isNotBlank() && !key.startsWith("sb_secret_")) {
                "Provide a non-empty Supabase publishable or legacy anon key."
            }
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" || it.name == "compileFlutterBuildRelease" }.configureEach {
    dependsOn(checkReleaseEndpoints)
}
