import 'package:digitos/models/puzzle.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/data_store/account_data_store.dart';
import 'package:digitos/services/data_store/game_data_store.dart';
import 'package:logging/logging.dart';

class GameService {
  final Logger _log = Logger('GameService');
  final GameDataStore gameDataStore;
  final AccountDataStore accountDataStore;
  final AuthService authService;

  // games user has seen in current app session
  // b/c user may skip some puzzle and we don't want to get one of those again
  Set<String> seenGameIds = {};
  int? selectedDifficulty;

  GameService({
    required this.gameDataStore,
    required this.accountDataStore,
    required this.authService,
  });

  // Get a puzzle that hasn't been played by the user
  Future<Puzzle?> getNewGame({
    int? difficulty,
  }) async {
    _log.info('getNewGame');

    var userId = authService.currentUser?.uid;

    var puzzleIdsToExclude = seenGameIds.toSet();
    if (userId != null) {
      // TODO shouldn't need to fetch this remotely every time.  Only on init app load, then should be able to manage locally
      var dbPlayedPuzzleIds = await accountDataStore.getPlayedPuzzleIds(userId);
      puzzleIdsToExclude.addAll(dbPlayedPuzzleIds);
    } else {
      _log.warning('getNewGame - user id is null');
    }

    var difficultyQuery = difficulty ?? selectedDifficulty;

    if (difficultyQuery != null) {
      // Fetch an arbitrary game configuration excluding the played ones
      Puzzle? newPuzzle = await gameDataStore.getPuzzleByDifficulty(
        // TODO respecting firestores 10 item limit for excluding documents, but need to get around this by eventually using a SQL db (nhost)
        excludedIds: puzzleIdsToExclude.take(10).toSet(),
        difficulty: difficultyQuery,
      );

      if (newPuzzle != null) {
        seenGameIds.add(newPuzzle.id);

        return newPuzzle;
      }

      _log.warning('No puzzle found');

      // TODO handle error
      return null;
    } else {
      _log.warning('getNewGame - difficulty is null');
      // Fetch an arbitrary game configuration excluding the played ones
      Puzzle? newPuzzle = await gameDataStore
          .getArbitraryPuzzleExcludingIds(puzzleIdsToExclude.toSet());

      if (newPuzzle != null) {
        seenGameIds.add(newPuzzle.id);

        return newPuzzle;
      }

      // TODO handle error
      return null;
    }
  }

  Future<Puzzle?> getDailyPuzzle() async {
    _log.info('getDailyPuzzle');
    var dailyPuzzle = await gameDataStore.getDailyPuzzle();

    if (dailyPuzzle != null) {
      seenGameIds.add(dailyPuzzle.id);
      return dailyPuzzle;
    } else {
      _log.info('getDailyPuzzle - no puzzle found');
      return null;
    }
  }
}
