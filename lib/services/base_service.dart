import 'package:flutter/foundation.dart';

class BaseService extends ChangeNotifier {
  // Common functionality that all services might share can be added here

  void notify() {
    notifyListeners();
  }

  // You can also include common methods that all services might need
}
