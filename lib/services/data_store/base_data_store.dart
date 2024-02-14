import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/services/app_logger.dart';

// abstracts remote data source (aka DB/firestore)
abstract class BaseDataStore {
  final FirebaseFirestore firestore;
  final _log = AppLogger('DataStore');

  BaseDataStore({required this.firestore}) {
    _log.info('DataStore initialized');
  }

  // Method to add a document to a collection
  Future<void> addDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    _log.info('addDocument: $collection, $data, $documentId');

    if (documentId != null) {
      await firestore.collection(collection).doc(documentId).set(data);
      return;
    }
    await firestore.collection(collection).add(data);
  }

  // Method to retrieve a document from a collection by its ID
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    _log.info('getDocument: $collection, $docId');

    return await firestore.collection(collection).doc(docId).get();
  }

  // Method to update a document in a collection by its ID
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    _log.info('updateDocument: $collection, $docId, $data');

    await firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> upsertDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    _log.info('upsertDocument: $collection, $docId, $data');

    await firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  // Method to delete a document from a collection by its ID
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    _log.info('deleteDocument: $collection, $docId');

    await firestore.collection(collection).doc(docId).delete();
  }

  Future<bool> documentExists(String collection, String docId) async {
    final docSnapshot = await firestore.collection(collection).doc(docId).get();
    return docSnapshot.exists;
  }
}
