import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/constants.dart';
import 'package:digitos/models/game_data.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class AccountService {
  // TODO this should use the datastore abstraction service
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final _log = Logger('AccountService');

  late final StreamSubscription<User?> _authSubscription;

  AccountService(this._authService) {
    // Constructor injection of AuthService

    // Set up a listener for user authentication changes
    _authSubscription = _authService.onAuthChanges.listen((user) {
      loadGameData();
      // Additional actions if needed
    });
  }

  GameData? _currentGameData;

  Future<void> saveGameData(GameData gameData) async {
    String userId = _authService.currentUser?.uid ?? "anonymous";
    await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(userId)
        .set(gameData.toJson());
  }

  // Method to transfer game data from anonymous to permanent account
  Future<void> transferGameDataToPermanentAccount(
    String newUserId,
    String? oldUserId,
  ) async {
    if (newUserId == oldUserId) {
      // Nothing to do
      _log.info(
          'transferGameDataToPermanentAccount: Old uid and new uid are the same, no need to migrate data.');
      return;
    }

    // Fetch game data from anonymous account
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
    String? userId = _authService.currentUser?.uid;

    if (userId == null) {
      // TODO Handle the case where there is no user ID
      _log.severe('loadGameData: No user ID found');

      return;
    }

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

    // ===== update the completed games list

    // Create a mutable copy of the gamesCompleted list
    var newGamesCompleted =
        List<CompletedGameData>.from(_currentGameData?.gamesCompleted ?? []);

    // Add the new completed game
    newGamesCompleted.add(CompletedGameData(
      puzzleId: puzzleId,
      moves: moves,
      completedAt: DateTime.now(),
    ));

    // ===== Update best score
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

  Future<void> updateUserName(String newName) async {
    String? userId = _authService.currentUser?.uid;
    // TODO enforce display name uniqueness

    if (userId == null) {
      // TODO Handle the case where there is no user ID
      _log.severe('changeUserName: No user ID found');

      return;
    }

    await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(userId)
        .update({
      'displayName': newName,
    });
  }

  void dispose() {
    _authSubscription.cancel();
  }
}
