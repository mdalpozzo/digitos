import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/data_store.dart';
import 'package:digitos/services/game_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> loadServices({
    required FirebaseOptions firebaseOptions,
  }) async {
    await Firebase.initializeApp(options: firebaseOptions);

    _getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
    _getIt.registerLazySingleton<DataStore>(
      () => DataStore(firestore: _getIt<FirebaseFirestore>()),
    );
    _getIt.registerLazySingleton<AuthService>(
        () => AuthService(dataStore: _getIt<DataStore>()));
    _getIt.registerLazySingleton<AccountService>(() => AccountService(
        authService: _getIt<AuthService>(), dataStore: _getIt<DataStore>()));
    _getIt.registerLazySingleton<GameService>(
        () => GameService(dataStore: _getIt<DataStore>()));
  }

  static T get<T extends Object>() {
    return _getIt.get<T>();
  }
}
