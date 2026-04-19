import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SecurityController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text Controllers
  final oldEmailController = TextEditingController();
  final newEmailController = TextEditingController();
  final currentPasswordController = TextEditingController();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password visibility toggles
  var showCurrentPassword = false.obs;
  var showOldPassword = false.obs;
  var showNewPassword = false.obs;
  var showConfirmPassword = false.obs;

  void toggleCurrentPassword() =>
      showCurrentPassword.value = !showCurrentPassword.value;
  void toggleOldPassword() => showOldPassword.value = !showOldPassword.value;
  void toggleNewPassword() => showNewPassword.value = !showNewPassword.value;
  void toggleConfirmPassword() =>
      showConfirmPassword.value = !showConfirmPassword.value;

  /// 🔹 Reauthenticate user before sensitive changes
  Future<bool> _reauthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final cred = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Re-authentication failed: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// 🔹 Update Email
  /// 🔹 Update Email (new flow)
  Future<void> updateEmail() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final oldEmail = oldEmailController.text.trim();
    final newEmail = newEmailController.text.trim();
    final password = currentPasswordController.text.trim();

    if (oldEmail.isEmpty || newEmail.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await _reauthenticate(oldEmail, password);
    if (!ok) return;

    try {
      // ✅ New API
      await user.verifyBeforeUpdateEmail(newEmail);

      Get.snackbar(
        "Verification Sent",
        "A confirmation link has been sent to $newEmail. Please verify to complete the update.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update email: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// 🔹 Update Password
  Future<void> updatePassword() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final email = _auth.currentUser?.email;
    if (email == null) return;

    final ok = await _reauthenticate(email, oldPass);
    if (!ok) return;

    try {
      await user.updatePassword(newPass);
      await user.reload();
      Get.snackbar(
        "Success",
        "Password updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update password: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    oldEmailController.dispose();
    newEmailController.dispose();
    currentPasswordController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SecurityController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Text Controllers
//   final oldEmailController = TextEditingController();
//   final newEmailController = TextEditingController();
//   final currentPasswordController = TextEditingController();

//   final oldPasswordController = TextEditingController();
//   final newPasswordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   // Password visibility toggles
//   var showCurrentPassword = false.obs;
//   var showOldPassword = false.obs;
//   var showNewPassword = false.obs;
//   var showConfirmPassword = false.obs;

//   void toggleCurrentPassword() =>
//       showCurrentPassword.value = !showCurrentPassword.value;
//   void toggleOldPassword() => showOldPassword.value = !showOldPassword.value;
//   void toggleNewPassword() => showNewPassword.value = !showNewPassword.value;
//   void toggleConfirmPassword() =>
//       showConfirmPassword.value = !showConfirmPassword.value;

//   /// 🔹 Reauthenticate helper (for password update)
//   Future<bool> _reauthenticateUser(String email, String password) async {
//     try {
//       final cred = EmailAuthProvider.credential(
//         email: email,
//         password: password,
//       );
//       await _auth.currentUser?.reauthenticateWithCredential(cred);
//       return true;
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Re-authentication failed: $e",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//   }

//   /// 🔹 Create new account with new email & update Firestore
//   Future<void> updateEmailWithNewAccount() async {
//     final oldEmail = oldEmailController.text.trim();
//     final newEmail = newEmailController.text.trim();
//     final password = currentPasswordController.text.trim();

//     if (oldEmail.isEmpty || newEmail.isEmpty || password.isEmpty) {
//       Get.snackbar(
//         "Error",
//         "All fields are required",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     try {
//       final oldUser = _auth.currentUser;
//       if (oldUser == null) return;
//       final oldUid = oldUser.uid;

//       // 🔹 Step 1: Create new account
//       UserCredential newUserCred = await _auth.createUserWithEmailAndPassword(
//         email: newEmail,
//         password: password,
//       );

//       final newUser = newUserCred.user;
//       if (newUser == null) throw Exception("New account creation failed");
//       final newUid = newUser.uid;

//       // 🔹 Step 2: Copy old Firestore data
//       final userDoc = FirebaseFirestore.instance
//           .collection("users")
//           .doc(oldUid);
//       final snapshot = await userDoc.get();

//       if (snapshot.exists) {
//         final oldData = snapshot.data()!;
//         await FirebaseFirestore.instance.collection("users").doc(newUid).set({
//           ...oldData,
//           "email": newEmail,
//         });
//       }

//       // 🔹 Step 3: Delete old user
//       await oldUser.delete();

//       Get.snackbar(
//         "Success",
//         "New email account created and Firestore updated!",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Failed: $e",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//     }
//   }

//   /// 🔹 Update Password
//   Future<void> updatePassword() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     final oldPass = oldPasswordController.text.trim();
//     final newPass = newPasswordController.text.trim();
//     final confirmPass = confirmPasswordController.text.trim();

//     if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
//       Get.snackbar(
//         "Error",
//         "All fields are required",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     if (newPass != confirmPass) {
//       Get.snackbar(
//         "Error",
//         "Passwords do not match",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     final email = _auth.currentUser?.email;
//     if (email == null) return;

//     final ok = await _reauthenticateUser(email, oldPass);
//     if (!ok) return;

//     try {
//       await user.updatePassword(newPass);
//       await user.reload();
//       Get.snackbar(
//         "Success",
//         "Password updated successfully",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Failed to update password: $e",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   void onClose() {
//     oldEmailController.dispose();
//     newEmailController.dispose();
//     currentPasswordController.dispose();
//     oldPasswordController.dispose();
//     newPasswordController.dispose();
//     confirmPasswordController.dispose();
//     super.onClose();
//   }
// }
