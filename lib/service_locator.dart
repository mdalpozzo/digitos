import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/data_store/account_data_store.dart';
import 'package:digitos/services/data_store/game_data_store.dart';
import 'package:digitos/services/game_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> loadServices({
    required FirebaseOptions firebaseOptions,
  }) async {
    await Firebase.initializeApp(options: firebaseOptions);

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
      ),
    );
  }

  static T get<T extends Object>() {
    return _getIt.get<T>();
  }
}
