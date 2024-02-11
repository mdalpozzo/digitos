import 'package:digitos/constants.dart';
import 'package:digitos/models/game_data.dart';
import 'package:digitos/services/data_store/base_data_store.dart';
import 'package:logging/logging.dart';

// account related DB operations
class AccountDataStore extends BaseDataStore {
  final Logger _log = Logger('AccountDataStore');

  AccountDataStore({required super.firestore});

  Future<void> transferGameDataToPermanentAccount(
    String newUserId,
    String? oldUserId,
  ) async {
    if (newUserId == oldUserId) {
      await upsertDocument(
        collection: FirestorePaths.USERS_COLLECTION,
        docId: newUserId,
        data: {'isAnonymous': false},
      );
      _log.info(
          "transferGameDataToPermanentAccount - Old UID and new UID are the same. Updated isAnonymous flag only.");
      return;
    }

    if (oldUserId != null) {
      Map<String, dynamic>? oldUserData = await fetchUserData(oldUserId);

      if (oldUserData != null) {
        await upsertDocument(
          collection: FirestorePaths.USERS_COLLECTION,
          docId: newUserId,
          data: oldUserData,
        );
        await deleteDocument(
          collection: FirestorePaths.USERS_COLLECTION,
          docId: oldUserId,
        );
      }
    } else {
      _log.warning('transferGameDataToPermanentAccount - old user id is null');
    }
  }

  Future<GameData?> loadGameData(String userId) async {
    _log.info('loadGameData');
    try {
      var snapshot = await getDocument(
        collection: FirestorePaths.USERS_COLLECTION,
        docId: userId,
      );

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data();
        if (data is Map<String, dynamic>) {
          return GameData.fromJson(data);
        }
      }
    } catch (e) {
      _log.severe("Error loading game data: $e");
    }

    return null; // No existing game data found or an error occurred
  }

  Future<void> updateGameData({
    required String userId,
    required Map<String, dynamic>
        data, // TODO should be using some kind of game data model instead of very generic Map type
  }) async {
    await updateDocument(
      collection: FirestorePaths.USERS_COLLECTION,
      docId: userId,
      data: data,
    );
  }

  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    await updateDocument(
      collection: FirestorePaths.USERS_COLLECTION,
      docId: userId,
      data: {
        "displayName": displayName,
      },
    );
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    var docSnapshot = await firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(userId)
        .get();
    return docSnapshot.exists ? docSnapshot.data() : null;
  }

  Future<void> deleteAccount(String userId) async {
    await deleteDocument(
      collection: FirestorePaths.USERS_COLLECTION,
      docId: userId,
    );
  }

  Future<Set<String>> getPlayedPuzzleIds(String userId) async {
    var userDoc = await getDocument(
      collection: FirestorePaths.USERS_COLLECTION,
      docId: userId,
    );

    // Fetch the list of played game configuration IDs for this user
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
    var playedGamesList = userData?['gamesCompleted'] as List<dynamic>? ?? [];

    // Use a Set to collect puzzleIds to ensure uniqueness
    Set<String> playedGameIds = {};

    // Iterate over playedGamesList and extract puzzleId from each game
    for (var game in playedGamesList) {
      if (game is Map<String, dynamic>) {
        var puzzleId = game['puzzleId'] as String?;
        if (puzzleId != null) {
          playedGameIds.add(puzzleId);
        }
      }
    }

    return playedGameIds;
  }
}
