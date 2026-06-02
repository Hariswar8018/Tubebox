import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'controllers/video_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  // Initialize GetX controllers
  Get.put(VideoController());
  
  runApp(const DisklyApp());
}

class DisklyApp extends StatelessWidget {
  const DisklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Diskly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
