import 'package:digitos/operations.dart';

operationEnumToDisplayString(OperationEnums? operation) {
  switch (operation) {
    case OperationEnums.add:
      return '+';
    case OperationEnums.subtract:
      return '-';
    case OperationEnums.multiply:
      return 'x';
    case OperationEnums.divide:
      return '/';
    default:
      return '_';
  }
}
