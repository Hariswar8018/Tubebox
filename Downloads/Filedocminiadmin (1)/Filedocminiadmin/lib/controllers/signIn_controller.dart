import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/controllers/ledger_controller.dart';
import 'package:file_dock/main.dart';
import 'package:file_dock/model/userModel.dart';
import 'package:file_dock/screens/signInScreen.dart';
import 'package:file_dock/services/firestore_services.dart';
import 'package:file_dock/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  // Make instances observable

  // Getter to access the user from the UI
  User? get user => _firebaseUser.value;

  //var user = Rxn<User>();
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  //final LedgerController ledgerController = Get.put(LedgerController());

  @override
  void onInit() {
    super.onInit();
    // Bind the user stream to the reactive variable
    _firebaseUser.bindStream(_auth.authStateChanges());
  }

  /// Signs in with Google and handles Firestore + Ledger.
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase sign-in
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user != null) {
        // 🔍 Check if Firestore user exists
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          // ✅ Create new UserModel
          final newUser = UserModel(
            uid: user.uid,
            userName: user.displayName ?? "Mini-Admin",
            email: user.email ?? "",
            userType: "mini-Admin",
          );

          await _firestoreService.saveUser(newUser);

          // ✅ Create ledger
          // await FirebaseFirestore.instance
          //     .collection("ledger")
          //     .doc(user.uid)
          //     .set({
          //       "approvedAmount": 0,
          //       "availableAmount": 0,
          //       "paidAmount": 0,
          //       "pendingAmount": 0,
          //       "totalEarnings": 0,
          //       "userId": user.uid,
          //     }, SetOptions(merge: true));
        }

        // Bind ledger always
        // ledgerController.bindLedger(user.uid);

        // Navigate to main screen
        //Get.offAll(() => MainScreen());
        Get.to(Root());
        // Get.to(() => MainScreen());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Sign-In Failed",
        e.message ?? "Something went wrong.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print("Google Sign-In Error: $e");
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

  /// Signs out the current user
  // Future<void> signOut() async {
  //   await _googleSignIn.signOut();
  //   await _auth.signOut();
  // }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      Get.offAll(() => const LoginWithGoogle()); // 👈 direct route reset
    } catch (e) {
      Get.snackbar("Error", "Logout failed: $e", colorText: Colors.white);
    }
  }
}
