import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class HomeViewModel with ChangeNotifier {
  final AccountService accountService;
  final GameService gameService;
  final _log = Logger('HomeViewModel');

  HomeViewModel({
    required this.accountService,
    required this.gameService,
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

  onPressLevelButton({int? difficulty}) async {
    _log.info('startNewGame');
    gameService.selectedDifficulty = difficulty;
    await gameService.getNewGame();
  }

  bool loggedIn = false;
  String? displayName;
  int? bestScore;
}
