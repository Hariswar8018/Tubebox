import 'package:file_dock/controllers/signIn_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../constant/colors.dart';

class LoginWithGoogle extends GetView<AuthController> {
  const LoginWithGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: kbg1black500,
            image: const DecorationImage(
              image: AssetImage("assets/images/register_bg.jpg"),
              fit: BoxFit.cover,
              opacity: 0.25,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Top Logo Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: kbg2lightblack300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/svg icons/logo.svg",
                      width: 33.75,
                      height: 30,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "File",
                            style: TextStyle(
                              color: kwhite,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "Dock",
                            style: TextStyle(
                              color: kblueaccent,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "Ad",
                            style: TextStyle(
                              color: kwhite,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// Main Body
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Title
                        Text(
                          "Welcome ",
                          style: TextStyle(
                            color: kwhite,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Sign in to continue ",
                          style: TextStyle(color: ktext2white200, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: size.height * 0.08),

                        /// Google Sign-In Button with GetX Obx
                        Obx(() {
                          return SizedBox(
                            width: 280,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.signInWithGoogle,
                              icon: Image.asset(
                                'assets/google_logo.png',
                                height: 26,
                              ),
                              label: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.black,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      "Continue with Google",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kwhite,
                                elevation: 3,
                                shadowColor: Colors.black.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          );
                        }),

                        SizedBox(height: size.height * 0.05),

                        /// Footer
                        Text(
                          "By continuing, you agree to our Terms & Privacy Policy",
                          style: TextStyle(color: ktext3white300, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
