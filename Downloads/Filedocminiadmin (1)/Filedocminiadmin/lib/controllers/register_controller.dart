import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/controllers/ledger_controller.dart';
import 'package:file_dock/model/userModel.dart';
import 'package:file_dock/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_dock/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  // Firebase instance
  final _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final LedgerController ledgerController = Get.put(LedgerController());

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController(); // ✅ Added username

  // Reactive variables for UI
  RxBool obscurePassword = true.obs;
  RxBool isLoading = false.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    super.onClose();
  }

  /// Registers a new user with Firebase using email and password
  Future<void> registerUser() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final userName = userNameController.text.trim();

      // Firebase registration
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        // ✅ Create UserModel
        final newUser = UserModel(
          uid: user.uid,
          userName: userName.isNotEmpty ? userName : "Mini-Admin",
          email: email,
          userType: "mini-Admin", // default role
        );

        // ✅ Save to Firestore
        await _firestoreService.saveUser(newUser);
        await FirebaseFirestore.instance
            .collection("ledger")
            .doc(user.uid)
            .set({
              "approvedAmount": 0,
              "availableAmount": 0,
              "paidAmount": 0,
              "pendingAmount": 0,
              "totalEarnings": 0,
              "userId": user.uid,
            }, SetOptions(merge: true));
        ledgerController.bindLedger(FirebaseAuth.instance.currentUser!.uid);
      }

      // Navigate to main screen
      Get.offAll(() => MainScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }
      Get.snackbar(
        "Registration Failed",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
