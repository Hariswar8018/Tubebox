import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/model/userModel.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save user only ONCE (at registration)
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.uid).set(user.toJson());
      print("✅ User saved successfully");
    } catch (e) {
      print("❌ Error saving user: $e");
    }
  }

  /// Update specific fields later
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection("users").doc(uid).update(data);
      print("✅ User updated successfully");
    } catch (e) {
      print("❌ Error updating user: $e");
    }
  }
}
