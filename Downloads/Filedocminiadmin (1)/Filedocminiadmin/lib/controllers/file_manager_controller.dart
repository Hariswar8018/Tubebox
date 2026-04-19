// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_dock/model/videoModel.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// class FileManagerController extends GetxController {
//   var files = <VideoModel>[].obs;

//   Future<void> fetchVideos() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection("videos")
//         .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//         .get();

//     files.value = snapshot.docs
//         .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
//         .toList();
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchVideos();
//   }

//   Future<void> onRefresh() async {
//     try {
//       await fetchVideos();
//       Get.snackbar("Refreshed", "Video list updated", colorText: Colors.black);
//     } catch (e) {
//       Get.snackbar("Error", "Failed to refresh: $e");
//     }
//   }

//   Future<void> deleteFile(int index) async {
//     try {
//       final video = files[index];

//       // 1. Delete Firestore document
//       await FirebaseFirestore.instance
//           .collection("videos")
//           .doc(video.id)
//           .delete();

//       // 2. Delete file from Firebase Storage (if stored there)
//       if (video.storageUrl != null && video.storageUrl!.isNotEmpty) {
//         final ref = FirebaseStorage.instance.refFromURL(video.storageUrl!);
//         await ref.delete();
//       }

//       // 3. Remove from local list
//       files.removeAt(index);

//       Get.snackbar("Deleted", "${video.title} removed successfully");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to delete: $e");
//     }
//   }

//   void copyFileLink(VideoModel video) {
//     Clipboard.setData(ClipboardData(text: "https://filedock/${video.id}"));
//     Get.snackbar("Copied", "https://filedock/${video.id}  link copied!");
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/model/videoModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FileManagerController extends GetxController {
  var files = <VideoModel>[].obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenVideos();
  }

  void _listenVideos() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    _subscription = FirebaseFirestore.instance
        .collection("videos")
        .where("userId", isEqualTo: uid)
        // .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
          files.value = snapshot.docs
              .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> refreshFiles() async {
    _subscription?.cancel();
    _listenVideos();
  }

  Future<void> deleteFile(int index) async {
    try {
      final video = files[index];

      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(video.id)
          .delete();

      // Decrease videoCount in user document
      await FirebaseFirestore.instance
          .collection("users")
          .doc(video.userId)
          .update({"videoCount": FieldValue.increment(-1)});

      // Delete from Firebase Storage
      if (video.storageUrl.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(video.storageUrl);
        await ref.delete();
      }

      // ❌ Don't do files.removeAt(index) because listener will handle it
      // files.removeAt(index);

      Get.snackbar(
        "Deleted",
        "${video.title} removed successfully",
        colorText: Colors.white,
      );
    } catch (e) {
      print("ERROR : ${e.toString()}");
      Get.snackbar("Error", "Failed to delete: $e", colorText: Colors.white);
    }
  }

  void copyFileLink(VideoModel video) {
    Clipboard.setData(ClipboardData(text: video.netlifyUrl));
    Get.snackbar(
      "Copied",
      colorText: Colors.white,
      "URL copied to clipboard",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
