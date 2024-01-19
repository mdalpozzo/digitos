import 'package:digitos/constants.dart';
import 'package:digitos/services/base_service.dart';
import 'package:digitos/services/data_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class AuthServiceError {
  final String message;
  final String code;

  AuthServiceError({
    required this.message,
    required this.code,
  });
}

class AuthService extends BaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DataStore dataStore;
  static final _log = Logger('AuthService');

  AuthService({required this.dataStore}) {
    // Automatically create an anonymous account if no user is logged in.
    _init();
  }

  Future<void> _init() async {
    if (_firebaseAuth.currentUser == null) {
      await signInAnonymously();
    }
  }

  // Stream to notify about authentication changes
  Stream<User?> get onAuthChanges => _firebaseAuth.authStateChanges();

  // Method to get the current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Method to sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    var userCred = await _firebaseAuth.signInAnonymously();

    String? anonymousUid = userCred.user?.uid;

    if (anonymousUid == null) {
      _log.warning(
          'signInAnonymously: Anonymous user ID is null, could not create anonymous user data');
      return userCred;
    }

    return userCred;
  }

  // Method to sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  // Method to link anonymous account to email and password (Optional)
  Future<UserCredential> linkAnonymousAccountToEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.currentUser!.linkWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
  }

  // Method to handle user login
  Future<void> loginUser(String email, String password) async {
    if (_firebaseAuth.currentUser?.isAnonymous ?? false) {
      // Handle anonymous account before logging in
      await _handleAnonymousAccount();
    }

    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Method to handle new account creation
  Future<UserCredential> createAccount(String email, String password) async {
    if (_firebaseAuth.currentUser?.isAnonymous ?? false) {
      // Link anonymous account data to the new account
      try {
        return await linkAnonymousAccountToEmailAndPassword(email, password);
      } catch (e) {
        if (e is FirebaseAuthException) {
          _log.severe("FirebaseAuth error: ${e.code}");
          if (e.code == "email-already-in-use") {
            throw AuthServiceError(
              message:
                  "Email is already in use. Please choose a different email.",
              code: e.code,
            );
          } else if (e.code == "user-not-found") {
            return await _createNewUserWithEmailAndPassword(email, password);
          } else {
            throw AuthServiceError(
              message: "An error occurred: ${e.message}",
              code: e.code,
            );
          }
        } else {
          // Handle other non-FirebaseAuth errors
          _log.severe("An error occurred: $e");
          throw AuthServiceError(
            message: "An error occurred: $e",
            code: "unknown",
          );
        }
      }
    } else {
      return await _createNewUserWithEmailAndPassword(email, password);
    }
  }

  Future<UserCredential> _createNewUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        _log.severe("FirebaseAuth error: ${e.code}");
        if (e.code == "email-already-in-use") {
          throw AuthServiceError(
            message:
                "Email is already in use. Please choose a different email.",
            code: e.code,
          );
        } else {
          throw AuthServiceError(
            message: "An error occurred: ${e.message}",
            code: e.code,
          );
        }
      } else {
        // Handle other non-FirebaseAuth errors
        _log.severe("An error occurred: $e");
        throw AuthServiceError(
          message: "An error occurred: $e",
          code: "unknown",
        );
      }
    }
  }

  // Handle anonymous account data before logging in or registering
  Future<void> _handleAnonymousAccount() async {
    _log.info('Handling anonymous account');
    // TODO Implement logic to delete anonymous account data or port it to the new account
    String? anonymousUserId = _firebaseAuth.currentUser?.uid;

    if (anonymousUserId != null) {
      // TODO this should be handled in the account services or some other higher level service class so that auth service does not depend on datastore
      _log.info('Deleting anonymous account data for user $anonymousUserId');
      await dataStore.deleteDocument(
        FirestorePaths.USERS_COLLECTION,
        anonymousUserId,
      );
    } else {
      _log.warning('Anonymous user ID is null');
    }
  }
}
