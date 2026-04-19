import 'package:file_dock/controllers/signIn_controller.dart';
import 'package:file_dock/controllers/withdrawal_controller.dart';

import 'package:file_dock/screens/main_screen.dart';
import 'package:file_dock/screens/signInScreen.dart';
import 'package:file_dock/screens/splashscreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).catchError((e) {
    Get.snackbar(
      "Init Error",
      e.toString(),
      colorText: Colors.white, // white snackbar text
    );
  });
  Get.put(AuthController(), permanent: true);
  Get.put(WithdrawalProvider(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      // home: Root(),
    );
  }
}

class Root extends GetWidget<AuthController> {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // controller.user is the reactive User? object from our controller
      return (controller.user != null) ? MainScreen() : LoginWithGoogle();
    });
  }
}
