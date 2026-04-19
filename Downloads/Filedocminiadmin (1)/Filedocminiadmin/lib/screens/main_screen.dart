import 'package:file_dock/screens/billing_screen.dart';
import 'package:file_dock/screens/file_manager_screen.dart';
import 'package:file_dock/screens/home_screen.dart';
import 'package:file_dock/screens/profile_screen.dart';
import 'package:file_dock/screens/upload_screen.dart';

import 'package:file_dock/widget/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/nav_controller.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  final NavController controller = Get.put(NavController());

  final List<String> _icons = [
    "assets/svg icons/bottom_nav_svg/home.svg",
    "assets/svg icons/bottom_nav_svg/upload.svg",
    "assets/svg icons/bottom_nav_svg/file_manager.svg",
    "assets/svg icons/bottom_nav_svg/billing.svg",
    "assets/svg icons/bottom_nav_svg/profile.svg",
  ];

  final List<Widget> pages = [
    HomeScreen(),     // ✅ your new Home Screen
    UploadScreen(),   // ✅ create this screen
    const FileManagerScreen(),    // ✅ create this screen
    BillingScreen(),    // ✅ create this screen
    ProfileScreen(),  // ✅ create this screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Obx(() => pages[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
        icons: _icons,
        selectedIndex: controller.selectedIndex.value,
        onTap: (index) => controller.changeIndex(index),
      )),
    );
  }
}
