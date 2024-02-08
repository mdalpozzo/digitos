// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
///

class FirebaseConfigParamsWeb {
  String apiKey;
  String appId;
  String messagingSenderId;
  String projectId;
  String authDomain;
  String databaseURL;
  String storageBucket;
  String measurementId;

  FirebaseConfigParamsWeb({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.authDomain,
    required this.databaseURL,
    required this.storageBucket,
    required this.measurementId,
  });
}

class FirebaseConfigParamsAndroid {
  String apiKey;
  String appId;
  String messagingSenderId;
  String projectId;
  String databaseURL;
  String storageBucket;

  FirebaseConfigParamsAndroid({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.databaseURL,
    required this.storageBucket,
  });
}

class FirebaseConfigParamsIos {
  String apiKey;
  String appId;
  String messagingSenderId;
  String projectId;
  String databaseURL;
  String storageBucket;
  String iosClientId;
  String iosBundleId;

  FirebaseConfigParamsIos({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.databaseURL,
    required this.storageBucket,
    required this.iosClientId,
    required this.iosBundleId,
  });
}

class FirebaseConfigParamsMacos {
  String apiKey;
  String appId;
  String messagingSenderId;
  String projectId;
  String databaseURL;
  String storageBucket;
  String iosBundleId;

  FirebaseConfigParamsMacos({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.databaseURL,
    required this.storageBucket,
    required this.iosBundleId,
  });
}

class DefaultFirebaseOptions {
  late FirebaseOptions webOptions;
  late FirebaseOptions androidOptions;
  late FirebaseOptions iosOptions;
  late FirebaseOptions macosOptions;

  DefaultFirebaseOptions({
    required FirebaseConfigParamsWeb web,
    required FirebaseConfigParamsAndroid android,
    required FirebaseConfigParamsIos ios,
    required FirebaseConfigParamsMacos macos,
  }) {
    webOptions = FirebaseOptions(
      apiKey: web.apiKey,
      appId: web.appId,
      messagingSenderId: web.messagingSenderId,
      projectId: web.projectId,
      authDomain: web.authDomain,
      databaseURL: web.databaseURL,
      storageBucket: web.storageBucket,
      measurementId: web.measurementId,
    );

    androidOptions = FirebaseOptions(
      apiKey: android.apiKey,
      appId: android.appId,
      messagingSenderId: android.messagingSenderId,
      projectId: android.projectId,
      databaseURL: android.databaseURL,
      storageBucket: android.storageBucket,
    );

    iosOptions = FirebaseOptions(
      apiKey: ios.apiKey,
      appId: ios.appId,
      messagingSenderId: ios.messagingSenderId,
      projectId: ios.projectId,
      databaseURL: ios.databaseURL,
      storageBucket: ios.storageBucket,
      iosClientId: ios.iosClientId,
      iosBundleId: ios.iosBundleId,
    );

    macosOptions = FirebaseOptions(
      apiKey: macos.apiKey,
      appId: macos.appId,
      messagingSenderId: macos.messagingSenderId,
      projectId: macos.projectId,
      databaseURL: macos.databaseURL,
      storageBucket: macos.storageBucket,
      iosBundleId: macos.iosBundleId,
    );
  }

  FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return webOptions;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidOptions;
      case TargetPlatform.iOS:
        return iosOptions;
      case TargetPlatform.macOS:
        return macosOptions;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
