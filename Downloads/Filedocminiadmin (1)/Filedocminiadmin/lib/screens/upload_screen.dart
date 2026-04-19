

import 'package:file_dock/controllers/nav_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant/colors.dart';
import '../controllers/file_manager_controller.dart';
import '../controllers/uploadcontroller.dart';
import '../widget/custom_app_bar.dart';

class InstagramPopup extends StatelessWidget {
  final String uid;

  const InstagramPopup({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(width:30,"assets/images/img.png"),
              const Text(
                "  Upload via Telegram",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "   "+uid,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: uid));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ UID Copied to ClipBoard")),
                    );
                  },
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final Uri telegramUrl = Uri.parse("https://t.me/FileDock_FileUploaderBot");

              if (await canLaunchUrl(telegramUrl)) {
                await launchUrl(
                  telegramUrl,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                throw "Could not open Telegram";
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0088CC), Color(0xFF005F99)], // Telegram vibe
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Open Telegram Bot",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Steps
          const Text(
            "Steps",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _step("1. Copy your UID from here"),
          _step("2. Open Telegram App from Web"),
          _step("3. Message Hi to user '@FileDock_FileUploaderBot'"),
          _step("4. Paste UID to Authenticate"),
          _step("5. Upload Video to Telegram and It will be updated"),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _step(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}
class UploadScreen extends StatelessWidget {
  UploadScreen({super.key});

  final UploadController controller = Get.put(UploadController());
  final NavController navController = Get.put(NavController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbg1black500,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/home_BG.jpg"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _title(),
                const SizedBox(height: 25),
                _cloudText(),
                const SizedBox(height: 10),
                _uploadBox(),
                const SizedBox(height: 20),
                _uploadButton(),
                const SizedBox(height: 13),
                _infoNote(),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () => _showInstagramPopup(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(width:30,"assets/images/img.png"),
                            const SizedBox(width: 12),
                            const Text(
                              "Upload via Telegram",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xff29A9EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _uploadedFilesHeader(),
                const SizedBox(height: 15),
                _uploadedFilesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInstagramPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => InstagramPopup(uid: FirebaseAuth.instance.currentUser!.uid),
    );
  }

  Widget _title() => Text(
    "Upload Videos",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kwhite),
  );

  Widget _cloudText() => Text(
    "FileDock Cloud",
    style: TextStyle(
      fontSize: 16,
      color: ktext2white200,
      fontWeight: FontWeight.w400,
    ),
  );

  Widget _uploadBox() => Container(
    width: double.infinity,
    height: 166,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: kbg2lightblack300,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          "Upload your files",
          style: TextStyle(
            color: kblueaccent,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        Icon(Icons.cloud_upload, color: kwhite, size: 46),
        const SizedBox(height: 18),
        Text(
          "Only Local Video Files.",
          style: TextStyle(color: ktext2white200, fontSize: 18),
        ),
      ],
    ),
  );

  Widget _uploadButton() => SizedBox(
    height: 49,
    width: 177,
    child: Obx(() {
      if (controller.isUploading.value) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "${controller.uploadProgress.value.toStringAsFixed(0)} % ",
            style:  TextStyle(
              color: kblueaccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: kblueaccent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: controller.pickAndUploadVideo,
        label: const Text(
          "Upload",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: const Icon(
          Icons.file_upload_outlined,
          color: Colors.black,
          size: 24,
        ),
      );
    }),
  );
  Widget _infoNote() => Text(
    "If you face issues with Jio Internet, please try using a VPN or set your DNS to Cloudflare DNS, as Jio has some DNS problems",
    textAlign: TextAlign.center,
    style: TextStyle(color: kwhite, fontSize: 14),
  );

  Widget _uploadedFilesHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _sectionTitle("Uploaded Files"),
      Row(
        children: [
          Text(
            "View All",
            style: TextStyle(color: ktext1white100, fontSize: 14),
          ),
          IconButton(
            onPressed: () {
              navController.changeIndex(2);
            },
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: ktext1white100,
              size: 18,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _uploadedFilesList() {
    final fileManagerController = Get.put(FileManagerController());

    return Obx(() {
      if (fileManagerController.files.isEmpty) {
        return Container(
          height: 147,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kbg2lightblack300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.file_copy, color: ktext2white200, size: 30),
                const SizedBox(height: 5),
                Text(
                  "No Uploaded Files",
                  style: TextStyle(color: ktext2white200, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: fileManagerController.files.map((video) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: ktext2white200.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.videocam, color: kblueaccent, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse("https://filedock.in/"+video.id))) {
                            await launchUrl(Uri.parse("https://filedock.in/"+video.id));
                          } else {
                            Get.snackbar(
                              "Error",
                              "Could not launch URL",
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: Text(
                          "https://filedock.in/"+video.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kblueaccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${(video.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                            style: TextStyle(
                              color: ktext3white300,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "${formatToIST(video.createdAt.toString())}  ",
                            style: TextStyle(
                              color: ktext3white300,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: video.netlifyUrl));
                    Get.snackbar(
                      "Copied",
                      colorText: Colors.white,
                      "URL copied to clipboard",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svg icons/file manager svg/copy.svg',
                    height: 24,
                    width: 24,
                    color: kblueaccent,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
  String formatToIST(String utcDateTime) {
    try {
      // Parse as UTC
      DateTime utc = DateTime.parse(utcDateTime).toUtc();

      // Convert to IST (+5:30)
      DateTime ist = utc.add(const Duration(hours: 5, minutes: 30));

      // Helpers
      String two(int n) => n.toString().padLeft(2, '0');

      // AM/PM logic
      int hour = ist.hour;
      String period = hour >= 12 ? "PM" : "AM";

      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;
      return "${two(ist.day)}/${two(ist.month)}/${ist.year} - ${two(hour12)}:${two(ist.minute)} $period";
    } catch (e) {
      return "NA";
    }
  }
  Widget _sectionTitle(String text) => IntrinsicWidth(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: ktext1white100,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: kblueaccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  );
}