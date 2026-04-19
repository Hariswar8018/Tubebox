import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/colors.dart';

class LoadingDialog {
  static void show({String message = "Loading..."}) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          // Allow back button / swipe back to close dialog
          return false;
        },
        child: Dialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kblueaccent),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true, // tap outside won't dismiss
      useSafeArea: true,
    );
  }

  static void hide() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
