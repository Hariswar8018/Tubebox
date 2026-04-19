// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// A reusable service for direct Firestore interactions.
class WithdrawalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream a single document for real-time updates.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getDocumentStream({
    required String collectionPath,
    required String docId,
  }) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  // Stream a collection with a filter.
  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream({
    required String collectionPath,
    required String field,
    required dynamic value,
  }) {
    return _firestore
        .collection(collectionPath)
        .where(field, isEqualTo: value)
        .snapshots();
  }

  // Add a new document to a collection.
  Future<void> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) {
    return _firestore.collection(collectionPath).add(data);
  }
}
