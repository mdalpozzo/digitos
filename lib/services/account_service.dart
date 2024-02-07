import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/constants.dart';
import 'package:digitos/models/game_data.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/data_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class AccountService {
  // TODO - should use the data store not _firestore directly
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService authService;
  final DataStore dataStore;

  final _log = Logger('AccountService');

  late final StreamSubscription<User?> _authSubscription;

  AccountService({
    required this.authService,
    required this.dataStore,
  }) {
    _log.info('AccountService.constructor - instantiating');
    // Constructor injection of AuthService

    // Set up a listener for user authentication changes
    _authSubscription = authService.onAuthChanges.listen((user) {
      loadGameData();
      // Additional actions if needed
    });
  }

  GameData? _currentGameData;

  Future<void> createNewAccountInDB(
    String userId, {
    bool? isAnonymous = false,
  }) async {
    _log.info('AccountService.createNewAccountInDB');
    // TODO - create another method to DELETE an account in DB / this can be called where ever createNewAccountInDB is called for cases where anonymous account is being migrated to a permanent account
    // check if account exists yet
    DocumentSnapshot result =
        await dataStore.getDocument(FirestorePaths.USERS_COLLECTION, userId);

    if (!result.exists) {
      _log.info('createNewAccountInDB: Creating new account for user $userId');
      await dataStore.addDocument(
        FirestorePaths.USERS_COLLECTION,
        {
          'displayName': '',
          'isAnonymous': isAnonymous,
          'isPremium': false, // TODO
          'lastLogin': DateTime.now(), // TODO update this on every login
        },
        documentId: userId,
      );
    } else {
      _log.info(
          'createNewAccountInDB: Account already exists for user $userId');
    }
  }

  Future<void> saveGameData(GameData gameData) async {
    _log.info('AccountService.saveGameData');
    String userId = authService.currentUser?.uid ?? "anonymous";
    await _firestore
        .collection(FirestorePaths.USERS_COLLECTION)
        .doc(userId)
        .set(gameData.toJson());

    notifyListeners();
  }

  // Method to transfer game data from anonymous to permanent account
  Future<void> transferGameDataToPermanentAccount(
    String newUserId,
    String? oldUserId,
  ) async {
    _log.info('AccountService.transferGameDataToPermanentAccount');
    if (newUserId == oldUserId) {
      // Only update the isAnonymous flag
      await _firestore
          .collection(FirestorePaths.USERS_COLLECTION)
          .doc(newUserId)
          .update({
        'isAnonymous': false,
      });

      _log.info(
          'transferGameDataToPermanentAccount: Old uid and new uid are the same, no need to migrate data.');
      return;
    }

    // Fetch game data from old account
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

    notifyListeners();
  }

  Future<void> loadGameData() async {
    _log.info('AccountService.loadGameData: Loading game data');
    String? userId = authService.currentUser?.uid;

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

    notifyListeners();
  }

  GameData? get currentGameData => _currentGameData;

  Future<void> addNewCompletedGame(String puzzleId, int moves) async {
    _log.info('AccountService.addNewCompletedGame');
    String? userId = authService.currentUser?.uid;

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
      'gamesCompleted': newGamesCompleted.map((e) => e.toJson()).toList(),
      'best': newBest,
    });

    // TODO could be a more efficient way to do this to avoid extra reads
    // proposal: move logic to the server side and use response to update local state
    // Fetch the updated game data
    await loadGameData();

    notifyListeners();
  }

  Future<void> updateUserName(String newName) async {
    _log.info('AccountService.updateUserName');
    String? userId = authService.currentUser?.uid;
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

    _currentGameData?.displayName = newName;

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
