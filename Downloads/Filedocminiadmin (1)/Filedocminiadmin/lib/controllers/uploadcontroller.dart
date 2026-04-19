import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/widget/loadingDialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UploadController extends GetxController {
  var isUploading = false.obs;
  final String firebaseDomain = "https://filedoc-64d48.firebaseapp.com/open";
  // final String firebaseDomain = "https://gleaming-kleicha-af0af3.netlify.app";

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Future<void> pickAndUploadVideo() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.video);

  //   if (result != null) {
  //     final file = File(result.files.single.path!);
  //     final fileName = result.files.single.name;
  //     final fileSize = await file.length();

  //     isUploading.value = true;
  //     LoadingDialog.show(message: "Uploading video...");

  //     try {
  //       final ref = FirebaseStorage.instance.ref().child(
  //         "videos/${DateTime.now().millisecondsSinceEpoch}_$fileName",
  //       );
  //       await ref.putFile(file);

  //       final downloadUrl = await ref.getDownloadURL();

  //       // Save in Firestore
  //       final doc = _db.collection("videos").doc();

  //       // Generate Netlify URL
  //       final netlifyUrl =
  //           "$firebaseDomain?videoUrl=${Uri.encodeComponent(downloadUrl)}&id=${doc.id}";

  //       await doc.set({
  //         "id": doc.id,
  //         "userId": FirebaseAuth.instance.currentUser!.uid,
  //         "title": fileName,
  //         "storageUrl": downloadUrl,
  //         "netlifyUrl": netlifyUrl,
  //         "size": fileSize,
  //         "views": 0,
  //         "clickCount": 0,
  //         "earnings": 0.0,
  //         "createdAt": DateTime.now(),
  //         "serverCreatedAt": FieldValue.serverTimestamp(),
  //       });

  //       // ✅ Update analytics collection
  //       String userId = FirebaseAuth.instance.currentUser!.uid;
  //       await updateDailyAnalytics(userId: userId, filesUploaded: 1);

  //       // Increment user video count
  //       await _db.collection("users").doc(userId).update({
  //         "videoCount": FieldValue.increment(1),
  //       });

  //       LoadingDialog.hide();
  //       Get.snackbar("Success", "Uploaded $fileName", colorText: Colors.white);
  //     } catch (e) {
  //       LoadingDialog.hide();
  //       Get.snackbar("Error", e.toString(), colorText: Colors.white);
  //     } finally {
  //       isUploading.value = false;
  //     }
  //   }
  // }
  var uploadProgress = 0.0.obs; // 0 → 100
  Future<void> pickAndUploadVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileSize = await file.length();

      isUploading.value = true;

      try {
        final ref = FirebaseStorage.instance.ref().child(
          "videos/${DateTime.now().millisecondsSinceEpoch}_$fileName",
        );
        UploadTask uploadTask = ref.putFile(file);

// listen to progress
        uploadTask.snapshotEvents.listen((event) {
          double progress =
              (event.bytesTransferred / event.totalBytes) * 100;

          uploadProgress.value = progress;
        });

// wait for completion
        await uploadTask;

        final downloadUrl = await ref.getDownloadURL();

        // Save in Firestore
        final doc = _db.collection("videos").doc();

        // ✅ Generate Netlify URL with only ID
        final netlifyUrl = "$firebaseDomain?id=${doc.id}";

        await doc.set({
          "id": doc.id,
          "userId": FirebaseAuth.instance.currentUser!.uid,
          "title": fileName,
          "storageUrl": downloadUrl,
          "netlifyUrl": netlifyUrl,
          "size": fileSize,
          "views": 0,
          "clickCount": 0,
          "earnings": 0.0,
          "createdAt": DateTime.now(),
          "serverCreatedAt": FieldValue.serverTimestamp(),
        });

        // ✅ Update analytics collection
        String userId = FirebaseAuth.instance.currentUser!.uid;
        await updateDailyAnalytics(userId: userId, filesUploaded: 1);

        // Increment user video count
        await _db.collection("users").doc(userId).update({
          "videoCount": FieldValue.increment(1),
        });

        Get.snackbar("Success", "Uploaded $fileName", colorText: Colors.white);
      } catch (e) {
        LoadingDialog.hide();
        Get.snackbar("Error", e.toString(), colorText: Colors.white);
      } finally {
        isUploading.value = false;
        uploadProgress.value = 0; // reset
      }
    }
  }

  /// Update analytics collection
  Future<void> updateDailyAnalytics({
    required String userId,
    int clicks = 0,
    double earnings = 0.0,
    int filesUploaded = 0,
  }) async {
    final todayId = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final docRef = _db
        .collection("analytics")
        .doc(userId)
        .collection("days")
        .doc(todayId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          "clicks": clicks,
          "earnings": earnings,
          "filesUploaded": filesUploaded,
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        transaction.update(docRef, {
          "clicks": (data["clicks"] ?? 0) + clicks,
          "earnings": (data["earnings"] ?? 0.0) + earnings,
          "filesUploaded": (data["filesUploaded"] ?? 0) + filesUploaded,
        });
      }
    });
  }
}
