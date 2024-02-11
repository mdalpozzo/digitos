import 'package:digitos/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class HomeViewModel with ChangeNotifier {
  final AccountService accountService;
  final _log = Logger('HomeViewModel');

  HomeViewModel({
    required this.accountService,
  }) {
    accountService.setDisplayNameChangedCallback((String newDisplayName) {
      _log.info('displayName changed to $newDisplayName');
      displayName = newDisplayName;
      notifyListeners();
    });

    accountService.setBestScoreChangedCallback((int newBestScore) {
      _log.info('bestScore changed to $newBestScore');
      bestScore = newBestScore;
      notifyListeners();
    });

    accountService.setLoggedInCallback((bool newLoggedIn) {
      _log.info('loggedIn changed to $newLoggedIn');
      loggedIn = newLoggedIn;
      notifyListeners();
    });
  }

  bool loggedIn = false;
  String? displayName;
  int? bestScore;
}
