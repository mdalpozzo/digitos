import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  // Common functionality that all view models might share can be added here

  // common methods that all services might need
  void notify() {
    notifyListeners();
  }
}
