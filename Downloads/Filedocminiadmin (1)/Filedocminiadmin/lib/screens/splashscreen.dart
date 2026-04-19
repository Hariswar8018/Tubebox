import 'package:file_dock/main.dart';
import 'package:file_dock/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../constant/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  double degToRad(double deg) => deg * 3.141592653589793 / 180;

  @override
  Widget build(BuildContext context) {
    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => Root());
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: kbg1black500,
        body: Stack(
          children: [
            /// Top-right SVG vector
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                "assets/svg icons/top_right_vector.svg",
                width: 463,
                height: 248,
              ),
            ),

            /// top-left
            Positioned(
              top: 0,
              left: 0,
              child: SvgPicture.asset(
                "assets/svg icons/top_left_vector.svg",
                width: 253,
                height: 260,
              ),
            ),

            /// Bottom-left SVG vector
            Positioned(
              bottom: 0,
              left: 0,
              child: SvgPicture.asset(
                "assets/svg icons/bottom_vector.svg",
                width: 477,
                height: 260,
              ),
            ),

            /// Center content
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 96),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Partnered With",
                      style: TextStyle(
                        color: kwhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 3),

                    /// FileDock Text
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Logo
                        SvgPicture.asset(
                          "assets/svg icons/logo.svg",
                          width: 55.12,
                          height: 49,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "File",
                          style: TextStyle(
                            color: kwhite,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Dock",
                          style: TextStyle(
                            color: kblueaccent,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 57),

                    Text(
                      "Upload.Earn.Withdraw",
                      style: TextStyle(
                        color: ktext1white100,
                        fontSize: 29,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 21),

                    /// Button with fixed size
                    SizedBox(
                      width: 249,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kblueaccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          // TODO: Navigate to Home/Next screen
                          Get.to(() => Root());
                        },
                        child: Text(
                          "Let's Go",
                          style: TextStyle(
                            color: kblack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
