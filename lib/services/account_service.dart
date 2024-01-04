import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/constants.dart';
import 'package:digitos/models/game_data.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:logging/logging.dart';

class AccountService {
  // TODO this should use the datastore abstraction service
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final _log = Logger('AccountService');

  GameData? _currentGameData;

  AccountService(this._authService); // Constructor injection of AuthService

  Future<void> saveGameData(GameData gameData) async {
    String userId = _authService.currentUser?.uid ?? "anonymous";
    await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(userId)
        .set(gameData.toJson());
  }

  // Method to transfer game data from anonymous to permanent account
  Future<void> transferGameDataToPermanentAccount(String newUserId) async {
    // Fetch game data from anonymous account
    String oldUserId = _authService.currentUser?.uid ?? "anonymous";
    DocumentSnapshot oldUserData = await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(oldUserId)
        .get();

    if (oldUserData.exists) {
      // Ensure the data is a Map<String, dynamic> before using it
      Map<String, dynamic> data =
          oldUserData.data() as Map<String, dynamic>? ?? {};

      // Save the data to the new user ID
      await _firestore
          .collection(FirestorePaths.USERS_COLLECTION)
          .doc(newUserId)
          .set(data);

      // Optionally delete the old data
      await _firestore
          .collection(FirestorePaths.USERS_COLLECTION)
          .doc(oldUserId)
          .delete();
    }
  }

  Future<void> loadGameData() async {
    String userId = _authService.currentUser?.uid ?? "anonymous";
    DocumentSnapshot snapshot = await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(userId)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      _currentGameData =
          GameData.fromJson(snapshot.data() as Map<String, dynamic>);
    } else {
      // TODO Handle the case where there is no existing game data
      _currentGameData = GameData();
    }
  }

  GameData? get currentGameData => _currentGameData;

  Future<void> addNewCompletedGame(String puzzleId, int moves) async {
    String? userId = _authService.currentUser?.uid;

    if (userId == null) {
      // TODO Handle the case where there is no user ID
      _log.severe('No user ID found');

      return;
    }

    // update the completed games list
    if (_currentGameData != null) {
      _currentGameData!.gamesCompleted.add(
        CompletedGameData(
          puzzleId: puzzleId,
          moves: moves,
          completedAt: DateTime.now(),
        ),
      );
    }

    // update best score
    int? prevBest = _currentGameData?.best;
    int newBest = prevBest ?? moves;
    if (moves < newBest) {
      newBest = moves;
    }

    await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(userId)
        .update({
      'games_completed':
          _currentGameData!.gamesCompleted.map((e) => e.toJson()).toList(),
      'best': newBest,
    });
  }
}
