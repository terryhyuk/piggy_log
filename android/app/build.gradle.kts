import java.util.Properties
import java.io.FileInputStream

/**
 * 1. 외부 설정 파일(key.properties) 로드
 * 보안을 위해 비밀번호와 키 경로를 코드에 직접 적지 않고 별도 파일에서 읽어옵니다.
 */
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { stream ->
        keystoreProperties.load(stream)
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 앱의 고유 패키지 명칭
    namespace = "com.terry.piggyLog"
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
        applicationId = "com.terry.piggyLog"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    /**
     * 2. 앱 서명 설정
     * 구글 플레이 스토어 배포를 위해 생성한 키스토어 파일 정보를 연결합니다.
     */
    signingConfigs {
        create("release") {
            // key.properties 파일에서 읽어온 값들을 할당
            keyAlias = keystoreProperties.getProperty("keyAlias") 
                ?: throw GradleException("key.properties: 'keyAlias' 누락")
            
            keyPassword = keystoreProperties.getProperty("keyPassword")
                ?: throw GradleException("key.properties: 'keyPassword' 누락")
            
            val storeFilePath = keystoreProperties.getProperty("storeFile")
                ?: throw GradleException("key.properties: 'storeFile' 누락")
            storeFile = file(storeFilePath)
            
            storePassword = keystoreProperties.getProperty("storePassword")
                ?: throw GradleException("key.properties: 'storePassword' 누락")
        }
    }

    buildTypes {
        release {
            /**
             * 3. 배포용 빌드 설정
             * 위에서 만든 'release' 서명 설정을 실제 출시용 빌드에 적용합니다.
             */
            signingConfig = signingConfigs.getByName("release")
            
            // 코드 최적화 및 리소스 축소 (출시 시 용량 최적화가 필요하면 true로 변경)
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}