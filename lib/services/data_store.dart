import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitos/services/base_service.dart';

class DataStore extends BaseService {
  // Private instance of the Cloud Firestore client
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a document to a collection
  Future<void> addDocument(String collection, Map<String, dynamic> data,
      {String? documentId}) async {
    if (documentId != null) {
      await _firestore.collection(collection).doc(documentId).set(data);
      return;
    }
    await _firestore.collection(collection).add(data);
  }

  // Method to retrieve a document from a collection by its ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Method to update a document in a collection by its ID
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Method to delete a document from a collection by its ID
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Retrieve an arbitrary document that doesn't match the provided set of documentIds
  Future<DocumentSnapshot?> getArbitraryDocumentExcludingIds(
      String collection, Set<String> excludedIds) async {
    Query query = _firestore.collection(collection);

    // Build a query excluding the documentIds
    for (String id in excludedIds) {
      query = query.where(FieldPath.documentId, isNotEqualTo: id);
    }

    // Fetch the documents and take the first one
    QuerySnapshot result = await query.limit(1).get();

    if (result.docs.isNotEmpty) {
      return result.docs.first;
    } else {
      return null;
    }
  }
}
