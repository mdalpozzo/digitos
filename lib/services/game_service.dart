import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/models/game_parameters.dart';
import 'package:digitos/services/data_store.dart';

class GameService {
  // Get a game configuration that hasn't been played by the user
  Future<GameParameters?> getNewGame(String userId) async {
    DocumentSnapshot userDoc = await DataStore().getDocument('users', userId);

    // Fetch the list of played game configuration IDs for this user
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
    List<String>? playedGameIds = userData != null
        ? List<String>.from(userData['gamesCompleted'] ?? [])
        : [];

    // Fetch an arbitrary game configuration excluding the played ones
    DocumentSnapshot<Object?>? newGameDoc = await DataStore()
        .getArbitraryDocumentExcludingIds('games', playedGameIds.toSet());
    Map<String, dynamic>? newGameData =
        newGameDoc?.data() as Map<String, dynamic>?;

    if (newGameData != null) {
      GameParameters gameParameters = GameParameters.fromJson(newGameData);
      return gameParameters;
    }

    return null;
  }
}
