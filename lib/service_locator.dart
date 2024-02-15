import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/app_lifecycle_service.dart';
import 'package:digitos/services/audio_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/data_store/account_data_store.dart';
import 'package:digitos/services/data_store/game_data_store.dart';
import 'package:digitos/services/game_service.dart';
import 'package:digitos/services/local_storage_service/local_storage_service.dart';
import 'package:digitos/services/local_storage_service/shared_preferences_service.dart';
import 'package:digitos/services/navigation_service.dart';
import 'package:digitos/services/settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> loadServices({
    required FirebaseOptions firebaseOptions,
    required GoRouter router,
  }) async {
    await Firebase.initializeApp(options: firebaseOptions);
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Register AppLifecycleService
    _getIt.registerSingleton<AppLifecycleService>(AppLifecycleService());

    // ===== FIREBASE
    _getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
    _getIt.registerLazySingleton<FirebaseAuth>(
      () => FirebaseAuth.instance,
    );

    // ===== DATA STORES
    _getIt.registerLazySingleton<AccountDataStore>(
      () => AccountDataStore(
        firestore: _getIt<FirebaseFirestore>(),
      ),
    );
    _getIt.registerLazySingleton<GameDataStore>(
      () => GameDataStore(
        firestore: _getIt<FirebaseFirestore>(),
      ),
    );

    // ===== SERVICES
    // Register SharedPreferencesService as LocalStorageService
    _getIt.registerLazySingleton<LocalStorageService>(
      () => SharedPreferencesService(),
    );
    _getIt.registerLazySingleton<AudioService>(
      () => AudioService(
        localStorageService: _getIt<LocalStorageService>(),
        appLifecycleService: _getIt<AppLifecycleService>(),
      ),
    );
    _getIt.registerLazySingleton<AuthService>(
      () => AuthService(
        accountDataStore: _getIt<AccountDataStore>(),
        firebaseAuth: _getIt<FirebaseAuth>(),
      ),
    );
    _getIt.registerLazySingleton<AccountService>(
      () => AccountService(
        authService: _getIt<AuthService>(),
        accountDataStore: _getIt<AccountDataStore>(),
      ),
    );
    _getIt.registerLazySingleton<GameService>(
      () => GameService(
        accountDataStore: _getIt<AccountDataStore>(),
        gameDataStore: _getIt<GameDataStore>(),
        authService: _getIt<AuthService>(),
      ),
    );
    _getIt.registerLazySingleton<SettingsService>(
      () => SettingsService(
        _getIt<LocalStorageService>(),
      ),
    );
    _getIt.registerLazySingleton<AudioService>(
      () => AudioService(
        localStorageService: _getIt<LocalStorageService>(),
        appLifecycleService: _getIt<AppLifecycleService>(),
      ),
    );
    _getIt.registerLazySingleton<NavigationService>(
      () => NavigationService(router),
    );
  }

  static T get<T extends Object>() {
    return _getIt.get<T>();
  }
}
