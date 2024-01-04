import 'package:digitos/constants.dart';
import 'package:digitos/services/data_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DataStore _dataStore = DataStore();
  static final _log = Logger('AuthService');

  AuthService() {
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
    return await _firebaseAuth.signInAnonymously();
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
  Future<void> createAccount(String email, String password) async {
    if (_firebaseAuth.currentUser?.isAnonymous ?? false) {
      // Link anonymous account data to the new account
      await linkAnonymousAccountToEmailAndPassword(email, password);
    } else {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  // Handle anonymous account data before logging in or registering
  Future<void> _handleAnonymousAccount() async {
    _log.info('Handling anonymous account');
    // TODO Implement logic to delete anonymous account data or port it to the new account
    String? anonymousUserId = _firebaseAuth.currentUser?.uid;

    if (anonymousUserId != null) {
      _log.info('Deleting anonymous account data for user $anonymousUserId');
      await _dataStore.deleteDocument(
        FirestorePaths.USERS_COLLECTION,
        anonymousUserId,
      );
    } else {
      _log.warning('Anonymous user ID is null');
    }
  }
}
