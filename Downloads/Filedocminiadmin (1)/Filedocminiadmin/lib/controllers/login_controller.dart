// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../screens/home_screen.dart';

// class LoginController extends GetxController {
//   final formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   var obscurePassword = true.obs;
//   var isLoading = false.obs;

//   void togglePasswordVisibility() {
//     obscurePassword.value = !obscurePassword.value;
//   }

//   void loginUser() async {
//     if (formKey.currentState!.validate()) {
//       isLoading.value = true;

//       final email = emailController.text.trim();
//       final password = passwordController.text.trim();

//       // TODO: Replace with backend/Firebase auth
//       await Future.delayed(Duration(seconds: 2));

//       isLoading.value = false;

//       if (email == "test@test.com" && password == "123456") {
//         Get.snackbar(
//           "Success",
//           "Logged in successfully",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green.withOpacity(0.7),
//           colorText: Colors.white,
//         );
//         Get.off(() => HomeScreen()); // Navigate to home
//       } else {
//         Get.snackbar(
//           "Error",
//           "Invalid email or password",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withOpacity(0.7),
//           colorText: Colors.white,
//         );
//       }
//     }
//   }
// }
// lib/controllers/login_controller.dart
import 'package:file_dock/model/userModel.dart';
import 'package:file_dock/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var obscurePassword = true.obs;
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // 🔹 Firebase sign in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 Get user data from Firestore
      final doc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        Get.snackbar(
          "Error",
          "User data not found in database",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
        return;
      }

      // 🔹 Convert Firestore doc to model
      UserModel currentUser = UserModel.fromSnapshot(doc);

      // ✅ Success
      Get.snackbar(
        "Success",
        "Welcome back, ${currentUser.userName}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      // 🔹 Navigate to Home
      Get.off(() => MainScreen());
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == "user-not-found") {
        message = "No user found with this email";
      } else if (e.code == "wrong-password") {
        message = "Incorrect password";
      }
      Get.snackbar(
        "Error",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
