import 'package:digitos/exceptions/app_exception.dart';

class DataStoreException extends AppException {
  DataStoreException({
    required super.message,
    super.code = "DATASTORE_ERROR",
    super.module = "DataStore",
  });
}
