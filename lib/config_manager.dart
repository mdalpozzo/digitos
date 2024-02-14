import 'package:digitos/firebase_options.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigManager {
  static final _log = AppLogger('ConfigManager');
  static final ConfigManager _instance = ConfigManager._internal();

  factory ConfigManager() {
    return _instance;
  }

  ConfigManager._internal();

  late DefaultFirebaseOptions firebaseConfig;

  Future<void> init() async {
    _log.info('init');
    await loadEnv();
    await loadFirebaseConfig();
  }

  Future<void> loadEnv() async {
    _log.info('Loading environment variables');
    await dotenv.load(fileName: ".env");
  }

  // env vars must be loaded first
  Future<void> loadFirebaseConfig() async {
    _log.info('Loading firebase options config');
    firebaseConfig = DefaultFirebaseOptions(
      web: FirebaseConfigParamsWeb(
        apiKey: firebaseWebApiKey,
        appId: firebaseWebAppId,
        messagingSenderId: firebaseWebMessagingSenderId,
        projectId: firebaseWebProjectId,
        authDomain: firebaseWebAuthDomain,
        databaseURL: firebaseWebDatabaseUrl,
        storageBucket: firebaseWebStorageBucket,
        measurementId: firebaseWebMeasurementId,
      ),
      android: FirebaseConfigParamsAndroid(
        apiKey: firebaseAndroidApiKey,
        appId: firebaseAndroidAppId,
        messagingSenderId: firebaseAndroidMessagingSenderId,
        projectId: firebaseAndroidProjectId,
        databaseURL: firebaseAndroidDatabaseUrl,
        storageBucket: firebaseAndroidStorageBucket,
      ),
      ios: FirebaseConfigParamsIos(
        apiKey: firebaseIosApiKey,
        appId: firebaseIosAppId,
        messagingSenderId: firebaseIosMessagingSenderId,
        projectId: firebaseIosProjectId,
        databaseURL: firebaseIosDatabaseUrl,
        storageBucket: firebaseIosStorageBucket,
        iosClientId: firebaseIosClientId,
        iosBundleId: firebaseIosBundleId,
      ),
      macos: FirebaseConfigParamsMacos(
        apiKey: firebaseMacosApiKey,
        appId: firebaseMacosAppId,
        messagingSenderId: firebaseMacosMessagingSenderId,
        projectId: firebaseMacosProjectId,
        databaseURL: firebaseMacosDatabaseUrl,
        storageBucket: firebaseMacosStorageBucket,
        iosBundleId: firebaseIosBundleId,
      ),
    );
  }

  // Generic method to get environment variables
  String? get(String name) => dotenv.env[name];

  // Specific getters for expected environment variables
  String get nhostGraphqlEndpoint {
    final endpoint = dotenv.env['NHOST_GRAPHQL_ENDPOINT'];
    if (endpoint == null) {
      throw Exception(
          'NHOST_GRAPHQL_ENDPOINT not found in environment variables');
    }
    return endpoint;
  }

  String get nhostGraphqlAdminSecret {
    final adminSecret = dotenv.env['NHOST_GRAPHQL_ADMIN_SECRET'];
    if (adminSecret == null) {
      throw Exception(
          'NHOST_GRAPHQL_ADMIN_SECRET not found in environment variables');
    }
    return adminSecret;
  }

  String get firebaseWebApiKey {
    final apiKey = dotenv.env['FIREBASE_WEB_API_KEY'];
    if (apiKey == null) {
      throw Exception(
          'FIREBASE_WEB_API_KEY not found in environment variables');
    }
    return apiKey;
  }

  String get firebaseWebAppId {
    final result = dotenv.env['FIREBASE_WEB_APP_ID'];
    if (result == null) {
      throw Exception('FIREBASE_WEB_APP_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseWebMessagingSenderId {
    final result = dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_WEB_MESSAGING_SENDER_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseWebProjectId {
    final result = dotenv.env['FIREBASE_WEB_PROJECT_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_WEB_PROJECT_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseWebAuthDomain {
    final result = dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'];
    if (result == null) {
      throw Exception(
          'FIREBASE_WEB_AUTH_DOMAIN not found in environment variables');
    }
    return result;
  }

  String get firebaseWebDatabaseUrl {
    final result = dotenv.env['FIREBASE_WEB_DATABASE_URL'];
    if (result == null) {
      throw Exception(
          'FIREBASE_WEB_DATABASE_URL not found in environment variables');
    }
    return result;
  }

  String get firebaseWebStorageBucket {
    final result = dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'];
    if (result == null) {
      throw Exception(
          'FIREBASE_WEB_STORAGE_BUCKET not found in environment variables');
    }
    return result;
  }

  String get firebaseWebMeasurementId {
    final result = dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_WEB_MEASUREMENT_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseAndroidApiKey {
    final result = dotenv.env['FIREBASE_ANDROID_API_KEY'];
    if (result == null) {
      throw Exception(
          'FIREBASE_ANDROID_API_KEY not found in environment variables');
    }
    return result;
  }

  String get firebaseAndroidAppId {
    final result = dotenv.env['FIREBASE_ANDROID_APP_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_ANDROID_APP_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseAndroidMessagingSenderId {
    final result = dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_ANDROID_MESSAGING_SENDER_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseAndroidProjectId {
    final result = dotenv.env['FIREBASE_ANDROID_PROJECT_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_ANDROID_PROJECT_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseAndroidDatabaseUrl {
    final result = dotenv.env['FIREBASE_ANDROID_DATABASE_URL'];
    if (result == null) {
      throw Exception(
          'FIREBASE_ANDROID_DATABASE_URL not found in environment variables');
    }
    return result;
  }

  String get firebaseAndroidStorageBucket {
    final result = dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'];
    if (result == null) {
      throw Exception(
          'FIREBASE_ANDROID_STORAGE_BUCKET not found in environment variables');
    }
    return result;
  }

  String get firebaseIosApiKey {
    final result = dotenv.env['FIREBASE_IOS_API_KEY'];
    if (result == null) {
      throw Exception(
          'FIREBASE_IOS_API_KEY not found in environment variables');
    }
    return result;
  }

  String get firebaseIosAppId {
    final result = dotenv.env['FIREBASE_IOS_APP_ID'];
    if (result == null) {
      throw Exception('FIREBASE_IOS_APP_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseIosMessagingSenderId {
    final result = dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_IOS_MESSAGING_SENDER_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseIosProjectId {
    final result = dotenv.env['FIREBASE_IOS_PROJECT_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_IOS_PROJECT_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseIosDatabaseUrl {
    final result = dotenv.env['FIREBASE_IOS_DATABASE_URL'];
    if (result == null) {
      throw Exception(
          'FIREBASE_IOS_DATABASE_URL not found in environment variables');
    }
    return result;
  }

  String get firebaseIosStorageBucket {
    final result = dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'];
    if (result == null) {
      throw Exception(
          'FIREBASE_IOS_STORAGE_BUCKET not found in environment variables');
    }
    return result;
  }

  String get firebaseIosClientId {
    final result = dotenv.env['FIREBASE_IOS_CLIENT_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_IOS_CLIENT_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseIosBundleId {
    final result = dotenv.env['FIREBASE_IOS_BUNDLE_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_IOS_BUNDLE_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseMacosApiKey {
    final result = dotenv.env['FIREBASE_MACOS_API_KEY'];
    if (result == null) {
      throw Exception(
          'FIREBASE_MACOS_API_KEY not found in environment variables');
    }
    return result;
  }

  String get firebaseMacosAppId {
    final result = dotenv.env['FIREBASE_MACOS_APP_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_MACOS_APP_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseMacosMessagingSenderId {
    final result = dotenv.env['FIREBASE_MACOS_MESSAGING_SENDER_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_MACOS_MESSAGING_SENDER_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseMacosProjectId {
    final result = dotenv.env['FIREBASE_MACOS_PROJECT_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_MACOS_PROJECT_ID not found in environment variables');
    }
    return result;
  }

  String get firebaseMacosDatabaseUrl {
    final result = dotenv.env['FIREBASE_MACOS_DATABASE_URL'];
    if (result == null) {
      throw Exception(
          'FIREBASE_MACOS_DATABASE_URL not found in environment variables');
    }
    return result;
  }

  String get firebaseMacosStorageBucket {
    final result = dotenv.env['FIREBASE_MACOS_STORAGE_BUCKET'];
    if (result == null) {
      throw Exception(
          'FIREBASE_MACOS_STORAGE_BUCKET not found in environment variables');
    }
    return result;
  }

  String get firebaseMacosIosBundleId {
    final result = dotenv.env['FIREBASE_MACOS_IOS_BUNDLE_ID'];
    if (result == null) {
      throw Exception(
          'FIREBASE_MACOS_IOS_BUNDLE_ID not found in environment variables');
    }
    return result;
  }
}
