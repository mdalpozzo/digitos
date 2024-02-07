import 'package:digitos/services/data_store.dart';
import 'package:get_it/get_it.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static void setup() {
    _getIt.registerLazySingleton<DataStore>(() => DataStore());
  }

  static T get<T extends Object>() {
    return _getIt.get<T>();
  }
}
