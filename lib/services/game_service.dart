import 'package:digitos/models/puzzle.dart';
import 'package:digitos/services/data_store/account_data_store.dart';
import 'package:digitos/services/data_store/game_data_store.dart';
import 'package:logging/logging.dart';

class GameService {
  final Logger _log = Logger('GameService');
  final GameDataStore gameDataStore;
  final AccountDataStore accountDataStore;

  // games user has seen in current app session
  Set<String> seenGameIds = {};

  GameService({
    required this.gameDataStore,
    required this.accountDataStore,
  });

  // Get a puzzle that hasn't been played by the user
  Future<Puzzle?> getNewGame(
    String userId, {
    int? difficulty,
  }) async {
    _log.info('getNewGame');

    // TODO shouldn't need to fetch this remotely every time.  Only on init app load, then should be able to manage locally
    var playedGameIds = await accountDataStore.getPlayedPuzzleIds(userId);

    // b/c user may skip some puzzle and we don't want to get one of those again
    playedGameIds.addAll(seenGameIds);

    if (difficulty != null) {
      // Fetch an arbitrary game configuration excluding the played ones
      Puzzle? newPuzzle = await gameDataStore.getPuzzleByDifficulty(
        // TODO respecting firestores 10 item limit for excluding documents, but need to get around this by eventually using a SQL db (nhost)
        excludedIds: playedGameIds.take(10).toSet(),
        difficulty: difficulty,
      );

      if (newPuzzle != null) {
        seenGameIds.add(newPuzzle.id);

        return newPuzzle;
      }

      _log.warning('No puzzle found');

      // TODO handle error
      return null;
    } else {
      // Fetch an arbitrary game configuration excluding the played ones
      Puzzle? newPuzzle = await gameDataStore
          .getArbitraryPuzzleExcludingIds(playedGameIds.toSet());

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
