// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_dock/model/userModel.dart';
// import 'package:file_dock/screens/login_screen.dart';
// import 'package:file_dock/screens/signInScreen.dart';
// import 'package:file_dock/screens/splashscreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class ProfileController extends GetxController {
//   final _auth = FirebaseAuth.instance;
//   final _db = FirebaseFirestore.instance;

//   final Rx<UserModel?> user = Rx<UserModel?>(null);
//   final isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserData();
//   }

//   // Future<void> fetchUserData() async {
//   //   try {
//   //     isLoading.value = true;
//   //     final firebaseUser = _auth.currentUser;

//   //     if (firebaseUser != null) {
//   //       final docSnapshot = await _db
//   //           .collection("users")
//   //           .doc(firebaseUser.uid)
//   //           .get();

//   //       if (docSnapshot.exists) {
//   //         user.value = UserModel.fromSnapshot(docSnapshot);
//   //       } else {
//   //         Get.snackbar("Error", "User profile data not found.");
//   //       }
//   //     }
//   //   } catch (e) {
//   //     Get.snackbar("Error", "Failed to fetch user data: ${e.toString()}");
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }

//   void fetchUserData() {
//     final firebaseUser = _auth.currentUser;

//     if (firebaseUser != null) {
//       _db
//           .collection("users")
//           .doc(firebaseUser.uid)
//           .snapshots() // ✅ realtime stream
//           .listen((docSnapshot) {
//             if (docSnapshot.exists) {
//               user.value = UserModel.fromSnapshot(docSnapshot);
//             } else {
//               Get.snackbar("Error", "User profile data not found.");
//             }
//           });
//     }
//   }

//   Future<void> refreshData() async {
//     try {
//       fetchUserData();
//       Get.snackbar("Data Refreshed", "Your Profile details Refreshed");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to refresh: $e");
//     }
//   }

//   Future<void> logout() async {
//     try {
//       await _auth.signOut();
//       Get.offAll(LoginWithGoogle());
//       Get.snackbar("Logged Out", "You have been logged out successfully.");
//     } catch (e) {
//       Get.snackbar("Logout Error", "Failed to log out: ${e.toString()}");
//     }
//   }

//   String get photoUrl {
//     // Prefer Firestore photoUrl, else Firebase Auth ka
//     return user.value?.photoUrl ?? _auth.currentUser?.photoURL ?? "";
//   }

//   /// --- Clean Getters for UI ---
//   String get userName => user.value?.userName ?? "";
//   String get email => user.value?.email ?? "";
//   int get videoCount => user.value?.videoCount ?? 0;
//   int get clicks => user.value?.clicks ?? 0;
//   double get earnings => user.value?.earnings ?? 0.0;
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/model/userModel.dart';
import 'package:file_dock/screens/login_screen.dart';
import 'package:file_dock/screens/signInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // listener handle
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  @override
  void onInit() {
    super.onInit();
    _subscribeToUserData();
  }

  void _subscribeToUserData() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _userStream = _db.collection("users").doc(firebaseUser.uid).snapshots();
      _userStream!.listen((docSnapshot) {
        if (docSnapshot.exists) {
          user.value = UserModel.fromSnapshot(docSnapshot);
        } else {
          Get.snackbar(
            "Error",
            "User profile data not found.",
            colorText: Colors.white,
          );
        }
      });
    }
  }

  Future<void> refreshData() async {
    // Optional: since realtime stream already updates automatically
    Get.snackbar(
      "Data Refreshed",
      "Your Profile details are up to date!",
      colorText: Colors.white,
    );
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      user.value = null;
      Get.offAll(() => LoginWithGoogle());
      Get.snackbar(
        "Logged Out",
        "You have been logged out successfully.",
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Logout Error",
        "Failed to log out: ${e.toString()}",
        colorText: Colors.white,
      );
    }
  }

  String get photoUrl =>
      user.value?.photoUrl ?? _auth.currentUser?.photoURL ?? "";

  /// --- Clean Getters for UI ---
  String get userName => user.value?.userName ?? "";

  String get email => user.value?.email ?? "";

  int get videoCount => user.value?.videoCount ?? 0;

  int get clicks => user.value?.clicks ?? 0;

  double get earnings => user.value?.earnings ?? 0.0;
}
