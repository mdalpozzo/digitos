import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/constants.dart';
import 'package:digitos/models/puzzle.dart';
import 'package:digitos/services/base_service.dart';
import 'package:digitos/services/data_store.dart';

class GameService extends BaseService {
  final DataStore dataStore;

  // games user has seen in current app session
  List<String> seenGameIds = [];

  GameService({required this.dataStore});

  // Get a game configuration that hasn't been played by the user
  Future<Puzzle?> getNewGame(
    String userId, {
    List<String> excludedPuzzleIds = const [],
    int? difficulty,
  }) async {
    DocumentSnapshot userDoc = await dataStore.getDocument('users', userId);

    // Fetch the list of played game configuration IDs for this user
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
    List<String>? playedGameIds = userData != null
        ? List<String>.from(userData['gamesCompleted'] ?? [])
        : [];
    playedGameIds.addAll(excludedPuzzleIds);
    playedGameIds.addAll(seenGameIds);

    if (difficulty != null) {
      // Fetch an arbitrary game configuration excluding the played ones
      DocumentSnapshot<Object?>? newGameDoc =
          await dataStore.getPuzzleByDifficulty(
        excludedIds: playedGameIds.toSet(),
        difficulty: difficulty,
      );

      Map<String, dynamic>? newGameData =
          newGameDoc?.data() as Map<String, dynamic>?;

      newGameData?['id'] = newGameDoc?.id;

      if (newGameData != null) {
        Puzzle gameParameters = Puzzle.fromJson(newGameData);
        seenGameIds.add(gameParameters.id);

        return gameParameters;
      }

      // TODO handle error
      return null;
    } else {
      // Fetch an arbitrary game configuration excluding the played ones
      DocumentSnapshot<Object?>? newGameDoc =
          await dataStore.getArbitraryPuzzleExcludingIds(playedGameIds.toSet());
      Map<String, dynamic>? newGameData =
          newGameDoc?.data() as Map<String, dynamic>?;

      newGameData?['id'] = newGameDoc?.id;

      if (newGameData != null) {
        Puzzle gameParameters = Puzzle.fromJson(newGameData);
        seenGameIds.add(gameParameters.id);

        return gameParameters;
      }

      // TODO handle error
      return null;
    }
  }

  Future<Puzzle?> getDailyPuzzle() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String todayStr =
        DateTime.now().toIso8601String().split('T')[0]; // yyyy-mm-dd format

    try {
      // First, try to find the ID of today's featured puzzle
      QuerySnapshot featuredSnapshot = await firestore
          .collection(FirestorePaths.DAILY_PUZZLE_COLLECTION)
          .where('date', isEqualTo: todayStr)
          .limit(1)
          .get();

      if (featuredSnapshot.docs.isEmpty) {
        // If not found, get the most recent puzzle ID from past dates
        featuredSnapshot = await firestore
            .collection(FirestorePaths.DAILY_PUZZLE_COLLECTION)
            .where('date', isLessThan: todayStr)
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if (featuredSnapshot.docs.isEmpty) {
          return null; // No featured puzzles found
        }
      }

      Map<String, dynamic>? dailyPuzzleRef =
          featuredSnapshot.docs.first.data() as Map<String, dynamic>?;

      if (dailyPuzzleRef == null) {
        return null; // No featured puzzles found
      }

      String? puzzleId =
          dailyPuzzleRef[FirestorePaths.DAILY_PUZZLE_ID_FIELD] as String?;

      if (puzzleId == null) {
        return null; // No featured puzzles found
      }

      // Fetch the game parameters using the puzzle ID
      DocumentSnapshot gameSnapshot = await dataStore.getDocument(
        FirestorePaths.PUZZLE_COLLECTION,
        puzzleId,
      );

      if (!gameSnapshot.exists) {
        return null; // Puzzle not found in main collection
      }

      Map<String, dynamic> gameData =
          gameSnapshot.data() as Map<String, dynamic>;
      gameData['id'] = gameSnapshot.id;
      seenGameIds.add(gameSnapshot.id);

      return Puzzle.fromJson(gameData);
    } catch (e) {
      print('Error fetching daily puzzle: $e');
      return null;
    }
  }
}
