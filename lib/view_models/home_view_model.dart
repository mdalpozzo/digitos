import 'dart:async';

import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/game_service.dart';
import 'package:digitos/view_models/base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  final AccountService accountService;
  final GameService gameService;
  static final _log = AppLogger('HomeViewModel');

  StreamSubscription? _bestScoreChangedSubscription;

  HomeViewModel({
    required this.accountService,
    required this.gameService,
  }) {
    accountService.displayName.listen((String? newDisplayName) {
      _log.info('displayName changed to $newDisplayName');
      displayName = newDisplayName;
      notifyListeners();
    });

    _bestScoreChangedSubscription =
        accountService.bestScore.listen((int? newBestScore) {
      _log.info('bestScore changed to $newBestScore');
      bestScore = newBestScore;
      notifyListeners();
    });

    accountService.loggedIn.listen((bool newLoggedIn) {
      _log.info('loggedIn changed to $newLoggedIn');
      loggedIn = newLoggedIn;
      notifyListeners();
    });
  }

  bool loggedIn = false;
  String? displayName;
  int? bestScore;

  @override
  void dispose() {
    _bestScoreChangedSubscription?.cancel();
    super.dispose();
  }
}
