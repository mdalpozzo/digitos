import 'package:digitos/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SettingsViewModel with ChangeNotifier {
  final AccountService accountService;
  final _log = Logger('SettingsViewModel');

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
