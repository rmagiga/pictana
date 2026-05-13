plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.optrig"
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
        applicationId = "com.example.optrig"
        // Android 14+ (API 34) を対象。SAF + Scoped Storage 制約下で動作。
        minSdk = 34
        targetSdk = flutter.targetSdkVersion
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

flutter {
    source = "../.."
}

dependencies {
    // SAF 操作をバックグラウンドスレッドで実行するためのコルーチンライブラリ
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    // DocumentFile.fromTreeUri() で SAF ツリー URI からファイル情報を取得
    implementation("androidx.documentfile:documentfile:1.0.1")
    // ActivityResultContracts.OpenDocumentTree() でフォルダ選択 Intent を起動
    implementation("androidx.activity:activity-ktx:1.9.3")
}
