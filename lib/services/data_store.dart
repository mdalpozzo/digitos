import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/services/base_service.dart';
import 'package:logging/logging.dart';

class DataStore extends BaseService {
  // Private instance of the Cloud Firestore client
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _log = Logger('DataStore');

  DataStore() {
    _log.info('DataStore initialized');
  }

  // Method to add a document to a collection
  Future<void> addDocument(String collection, Map<String, dynamic> data,
      {String? documentId}) async {
    _log.info('DataStore.addDocument: $collection, $data, $documentId');

    if (documentId != null) {
      await _firestore.collection(collection).doc(documentId).set(data);
      return;
    }
    await _firestore.collection(collection).add(data);
  }

  // Method to retrieve a document from a collection by its ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    _log.info('DataStore.getDocument: $collection, $docId');

    return await _firestore.collection(collection).doc(docId).get();
  }

  // Method to update a document in a collection by its ID
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    _log.info('DataStore.updateDocument: $collection, $docId, $data');

    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Method to delete a document from a collection by its ID
  Future<void> deleteDocument(String collection, String docId) async {
    _log.info('DataStore.deleteDocument: $collection, $docId');

    await _firestore.collection(collection).doc(docId).delete();
  }

  // Retrieve an arbitrary document that doesn't match the provided set of documentIds
  Future<DocumentSnapshot?> getArbitraryPuzzleExcludingIds(
    String collection,
    Set<String> excludedIds,
  ) async {
    _log.info(
        'DataStore.getArbitraryPuzzleExcludingIds: $collection, $excludedIds');

    Query query = _firestore
        .collection(collection)
        .where(FieldPath.documentId, whereNotIn: excludedIds);

    // Fetch the documents and take the first one
    QuerySnapshot result = await query.limit(1).get();

    if (result.docs.isNotEmpty) {
      return result.docs.first;
    } else {
      return null;
    }
  }

  // Retrieve an arbitrary document from a difficulty level
  Future<DocumentSnapshot?> getPuzzleByDifficulty(
    String collection,
    String difficulty,
  ) async {
    _log.info('DataStore.getPuzzleByDifficulty: $collection, $difficulty');

    int? difficultyInt = int.tryParse(difficulty);

    if (difficultyInt == null) {
      return await getArbitraryPuzzleExcludingIds(collection, {});
    }

    Query query = _firestore
        .collection(collection)
        .where('difficulty', isEqualTo: difficultyInt);

    // Fetch the documents and take the first one
    QuerySnapshot result = await query.limit(1).get();

    if (result.docs.isNotEmpty) {
      return result.docs.first;
    } else {
      _log.warning('No puzzles found for difficulty: $difficulty');

      return null;
    }
  }
}
