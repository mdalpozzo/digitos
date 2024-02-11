import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/constants.dart';
import 'package:digitos/models/puzzle.dart';
import 'package:digitos/services/data_store/base_data_store.dart';
import 'package:logging/logging.dart';

// db operations related to the game aspect of the app (e.g. fetching puzzles, ...)
class GameDataStore extends BaseDataStore {
  Logger _log = Logger('GameDataStore');

  GameDataStore({required super.firestore});

  // Retrieve an arbitrary document that doesn't match the provided set of documentIds
  Future<Puzzle?> getArbitraryPuzzleExcludingIds(
    Set<String> excludedIds,
  ) async {
    _log.info('getArbitraryPuzzleExcludingIds: excludedPuzzles: $excludedIds');

    Query query = firestore.collection(FirestorePaths.PUZZLE_COLLECTION);

    // Only add the whereNotIn filter if excludedIds is not empty
    if (excludedIds.isNotEmpty) {
      List<String> limitedExcludedIds = excludedIds.toList();

// Ensure the list does not exceed 10 items
      if (limitedExcludedIds.length > 10) {
        limitedExcludedIds = limitedExcludedIds.sublist(0, 10);
      }

      query = query.where(
        FieldPath.documentId,
        whereNotIn: limitedExcludedIds.toList(),
      );
    }

    // Fetch the documents and take the first one
    QuerySnapshot result = await query.limit(1).get();

    if (result.docs.isNotEmpty) {
      final data = result.docs.first.data() as Map<String,
          dynamic>?; // Ensuring data is cast as Map<String, dynamic>
      if (data != null) {
        data['id'] = result.docs.first.id; // Add the document ID to the data
        return Puzzle.fromJson(data);
      } else {
        _log.warning('Data fetched is not a Map<String, dynamic>');
      }
    }
    return null;
  }

  // Retrieve an arbitrary document from a difficulty level
  Future<Puzzle?> getPuzzleByDifficulty({
    required int difficulty,
    required Set<String> excludedIds,
  }) async {
    _log.info('getPuzzleByDifficulty: difficulty: $difficulty');

    Query query = firestore
        .collection(FirestorePaths.PUZZLE_COLLECTION)
        .where('difficulty', isEqualTo: difficulty);

    // Fetch the documents and take the first one
    QuerySnapshot result = await query.limit(1).get();

    if (result.docs.isNotEmpty) {
      final data = result.docs.first.data();
      if (data is Map<String, dynamic>) {
        data['id'] = result.docs.first.id; // Add the document ID to the data
        return Puzzle.fromJson(data);
      } else {
        _log.warning('Data fetched is not a Map<String, dynamic>');
        return null;
      }
    } else {
      _log.warning('No puzzles found for difficulty: $difficulty');

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
      DocumentSnapshot gameSnapshot = await getDocument(
        collection: FirestorePaths.PUZZLE_COLLECTION,
        docId: puzzleId,
      );

      if (!gameSnapshot.exists) {
        return null; // Puzzle not found in main collection
      }

      final data = gameSnapshot.data();
      if (data is Map<String, dynamic>) {
        data['id'] = gameSnapshot.id; // Add the document ID to the data
        return Puzzle.fromJson(data);
      } else {
        _log.warning('Data fetched is not a Map<String, dynamic>');
        return null;
      }
    } catch (e) {
      print('Error fetching daily puzzle: $e');
      return null;
    }
  }
}
