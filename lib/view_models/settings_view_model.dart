import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:flutter/material.dart';

class SettingsViewModel with ChangeNotifier {
  final AccountService accountService;
  static final _log = AppLogger('SettingsViewModel');

  SettingsViewModel({
    required this.accountService,
  }) {
    accountService.setDisplayNameChangedCallback((String newDisplayName) {
      _log.info('displayName changed to $newDisplayName');
      displayName = newDisplayName;
      notifyListeners();
    });
  }

  String? displayName;
}
