import 'package:file_dock/controllers/signIn_controller.dart';
import 'package:file_dock/controllers/withdrawal_controller.dart';
import 'package:file_dock/screens/security_screen.dart';
import 'package:file_dock/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/colors.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final WithdrawalProvider wcontroller = Get.put(WithdrawalProvider());

  final AuthController authcontroller = Get.put(AuthController());
  final photo = Get.find<ProfileController>().photoUrl;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kbg1black500,
        appBar: CustomAppBar(onRefresh: controller.refreshData),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
          },
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/register_bg.jpg"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),

                /// Profile Card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            /// Background Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              margin: const EdgeInsets.only(top: 60),
                              decoration: BoxDecoration(
                                color: kbg2lightblack300,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 60),

                                  /// Username
                                  Obx(
                                    () => RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: ktext1white100,
                                          fontSize: 16,
                                        ),
                                        children: [
                                          const TextSpan(text: "User Name : "),
                                          TextSpan(
                                            text: controller.userName,
                                            style: TextStyle(
                                              color: kwhite,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  /// Email
                                  Obx(
                                    () => RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: ktext1white100,
                                          fontSize: 16,
                                        ),
                                        children: [
                                          const TextSpan(text: "Email : "),
                                          TextSpan(
                                            text: controller.email,
                                            style: TextStyle(
                                              color: kwhite,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  /// No of videos
                                  Obx(
                                    () => RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: ktext1white100,
                                          fontSize: 16,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "No. of Videos : ",
                                          ),
                                          TextSpan(
                                            text: "${controller.videoCount}",
                                            style: TextStyle(
                                              color: kwhite,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  /// Total Clicks & Earnings
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(
                                        () => RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: ktext1white100,
                                              fontSize: 18,
                                            ),
                                            children: [
                                              const TextSpan(text: "Clicks : "),
                                              TextSpan(
                                                text: "${controller.clicks}",
                                                style: TextStyle(
                                                  color: kwhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: ktext1white100,
                                              fontSize: 18,
                                            ),
                                            children: [
                                              const TextSpan(text: "Earned : "),
                                              TextSpan(
                                                text:
                                                    "Rs ${wcontroller.approvedAmount.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  color: kwhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  /// Security Button
                                  // SizedBox(
                                  //   width: double.infinity,
                                  //   child: ElevatedButton.icon(
                                  //     style: ElevatedButton.styleFrom(
                                  //       backgroundColor: Colors.grey.shade800,
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(
                                  //           25,
                                  //         ),
                                  //       ),
                                  //       padding: const EdgeInsets.symmetric(
                                  //         vertical: 14,
                                  //       ),
                                  //     ),
                                  //     onPressed: () {
                                  //       Get.to(SecurityScreen());
                                  //     },
                                  //     icon: const Icon(
                                  //       Icons.lock,
                                  //       color: Colors.white,
                                  //     ),
                                  //     label: const Text(
                                  //       "Security",
                                  //       style: TextStyle(
                                  //         color: Colors.white,
                                  //         fontSize: 18,
                                  //         fontWeight: FontWeight.w500,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  const SizedBox(height: 16),

                                  /// Logout Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      onPressed: authcontroller.signOut,
                                      icon: const Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        "LogOut",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Profile Image
                            /// Profile Image
                            Obx(() {
                              final photo = controller.photoUrl;
                              final name = controller.userName;

                              return Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey.shade800,
                                  child: photo.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            photo,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.person,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                          ),
                                        )
                                      : Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : "G",
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
