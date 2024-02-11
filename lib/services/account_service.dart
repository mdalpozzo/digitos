import 'dart:async';

import 'package:digitos/constants.dart';
import 'package:digitos/models/game_data.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/data_store/account_data_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

// anything to do with account logic (auth is separate lower level service)
class AccountService {
  final AuthService authService;
  final AccountDataStore accountDataStore;

  final _log = Logger('AccountService');

  late final StreamSubscription<User?> _authSubscription;

  AccountService({
    required this.authService,
    required this.accountDataStore,
  }) {
    _log.info('AccountService.constructor - instantiating');
    // Constructor injection of AuthService

    // Set up a listener for user authentication changes
    _authSubscription = authService.onAuthChanges.listen((user) {
      // TODO probably need to consider the impact on the UX/UI or app logic given the async nature of this operation
      loadAccountGameData();
      // Additional actions if needed
    });
  }

  GameData? _currentGameData;

  Future<void> createNewAccountInDB(String userId,
      {bool? isAnonymous = false}) async {
    bool accountExists = await accountDataStore.documentExists(
        FirestorePaths.USERS_COLLECTION, userId);
    if (!accountExists) {
      _log.info('createNewAccountInDB: Creating new account for user $userId');
      await accountDataStore.addDocument(
        collection: FirestorePaths.USERS_COLLECTION,
        data: {
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
    _log.info('saveGameData');
    String userId = authService.currentUser?.uid ?? "anonymous";
    await accountDataStore.upsertDocument(
      docId: userId,
      data: gameData.toJson(),
      collection: FirestorePaths.USERS_COLLECTION,
    );
  }

  // Method to transfer game data from anonymous to permanent account
  Future<void> transferGameDataToPermanentAccount(
    String newUserId,
    String? oldUserId,
  ) async {
    _log.info('transferGameDataToPermanentAccount');
    await accountDataStore.transferGameDataToPermanentAccount(
        newUserId, oldUserId);
    _log.info("Game data transferred successfully.");
  }

  Future<void> loadAccountGameData() async {
    _log.info('AccountService.loadAccountGameData: Loading game data');
    String? userId = authService.currentUser?.uid;

    if (userId == null) {
      _log.severe('loadAccountGameData: No user ID found');
      return;
    }

    GameData? gameData = await accountDataStore.loadGameData(userId);
    if (gameData != null) {
      _currentGameData = gameData;
    } else {
      // no existing game data, use default game data
      _currentGameData = GameData();
    }
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

    await accountDataStore.updateGameData(
      userId: userId,
      data: {
        'gamesCompleted': newGamesCompleted.map((e) => e.toJson()).toList(),
        'best': newBest,
      },
    );

    // TODO could be a more efficient way to do this to avoid extra reads
    // proposal: move logic to the server side and use response to update local state
    // Fetch the updated game data
    // OR
    // return updated game data from accountDataStore.updateGameData and update local app state
    await loadAccountGameData();
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

    await accountDataStore.updateDisplayName(
      userId: userId,
      displayName: newName,
    );

    _currentGameData?.displayName = newName;
  }

// these seem to granular... do i really need each separate value to have its own callback?
  Function(int)? onBestScoreChanged;

  void setBestScoreChangedCallback(Function(int) callback) {
    onBestScoreChanged = callback;
  }

  void updateBestScore(int newBestScore) {
    var callback = onBestScoreChanged;
    if (callback != null) callback(newBestScore);
  }

  Function(String)? onDisplayNameChanged;

  void setDisplayNameChangedCallback(Function(String) callback) {
    onDisplayNameChanged = callback;
  }

  void updateDisplayName(String newDisplayName) {
    var callback = onDisplayNameChanged;
    if (callback != null) callback(newDisplayName);
  }

  Function(bool)? onLoggedInChanged;

  void setLoggedInCallback(Function(bool) callback) {
    onLoggedInChanged = callback;
  }

  void updateLoggedIn(bool newLoggedIn) {
    var callback = onLoggedInChanged;
    if (callback != null) callback(newLoggedIn);
  }

  void dispose() {
    _authSubscription.cancel();
  }
}
