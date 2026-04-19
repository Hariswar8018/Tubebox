// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A reusable service for Firebase Storage operations.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Uploads a file to a specific path in Firebase Storage.
  Future<String> uploadFile({required String path, required File file}) async {
    final uid = _auth.currentUser!.uid;
    final fileName = path.split('/').last;
    final ref = _storage.ref('qr_codes/$uid/$fileName');
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
}
