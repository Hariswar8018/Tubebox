// import 'package:file_dock/controllers/login_controller.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import '../constant/colors.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});
//   final LoginController controller = Get.put(LoginController());

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           decoration: BoxDecoration(
//             color: kbg1black500,

//             image: const DecorationImage(
//               image: AssetImage("assets/images/register_bg.jpg"),
//               fit: BoxFit.cover,
//               opacity: 0.25,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               /// App bar logo
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 color: kbg2lightblack300,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SvgPicture.asset(
//                       "assets/svg icons/logo.svg",
//                       width: 33.75,
//                       height: 30,
//                     ),
//                     const SizedBox(width: 8),
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "File",
//                             style: TextStyle(
//                               color: kwhite,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           TextSpan(
//                             text: "Dock",
//                             style: TextStyle(
//                               color: kblueaccent,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           TextSpan(
//                             text: "Ad",
//                             style: TextStyle(
//                               color: kwhite,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 100),

//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Form(
//                     key: controller.formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Center(
//                           child: Text(
//                             "Login",
//                             style: TextStyle(
//                               color: kwhite,
//                               fontSize: 40,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 45),

//                         Text(
//                           "Email",
//                           style: TextStyle(
//                             color: ktext1white100,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         TextFormField(
//                           controller: controller.emailController,
//                           style: TextStyle(color: kwhite),
//                           decoration: _inputDecoration("Enter user name"),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Email is required";
//                             }
//                             if (!GetUtils.isEmail(value.trim())) {
//                               return "Enter a valid email";
//                             }
//                             return null;
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         Text(
//                           "Password",
//                           style: TextStyle(
//                             color: ktext1white100,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Obx(
//                           () => TextFormField(
//                             controller: controller.passwordController,
//                             style: TextStyle(color: kwhite),
//                             obscureText: controller.obscurePassword.value,
//                             decoration: _inputDecoration("Enter password")
//                                 .copyWith(
//                                   suffixIcon: IconButton(
//                                     icon: Icon(
//                                       controller.obscurePassword.value
//                                           ? Icons.visibility_off
//                                           : Icons.visibility,
//                                       color: ktext3white300,
//                                     ),
//                                     onPressed:
//                                         controller.togglePasswordVisibility,
//                                   ),
//                                 ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return "Password is required";
//                               }
//                               if (value.length < 6) {
//                                 return "Password must be at least 6 chars";
//                               }
//                               return null;
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 12),

//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             TextButton(
//                               onPressed: () async {
//                                 final email = controller.emailController.text
//                                     .trim();
//                                 if (email.isEmpty) {
//                                   Get.snackbar(
//                                     "Error",
//                                     "Please enter your email first",
//                                     snackPosition: SnackPosition.BOTTOM,
//                                     backgroundColor: Colors.red.withOpacity(
//                                       0.7,
//                                     ),
//                                     colorText: Colors.white,
//                                   );
//                                 } else {
//                                   try {
//                                     await FirebaseAuth.instance
//                                         .sendPasswordResetEmail(email: email);
//                                     Get.snackbar(
//                                       "Success",
//                                       "Password reset link sent to $email",
//                                       snackPosition: SnackPosition.BOTTOM,
//                                       backgroundColor: Colors.green.withOpacity(
//                                         0.7,
//                                       ),
//                                       colorText: Colors.white,
//                                     );
//                                   } catch (e) {
//                                     Get.snackbar(
//                                       "Error",
//                                       e.toString(),
//                                       snackPosition: SnackPosition.BOTTOM,
//                                       backgroundColor: Colors.red.withOpacity(
//                                         0.7,
//                                       ),
//                                       colorText: Colors.white,
//                                     );
//                                   }
//                                 }
//                               },
//                               child: Text(
//                                 "Forgot Password ?",
//                                 style: TextStyle(color: ktext2white200),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Get.to(() => RegisterScreen());
//                               },
//                               child: Text(
//                                 "Sign up.",
//                                 style: TextStyle(color: kwhite),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 40),

//                         Center(
//                           child: SizedBox(
//                             width: 209,
//                             height: 50,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: kblueaccent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                               ),
//                               onPressed: controller.loginUser,
//                               child: Text(
//                                 "Login",
//                                 style: TextStyle(
//                                   color: kblack,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       filled: true,
//       fillColor: kbg2lightblack300,
//       hintText: hint,
//       hintStyle: TextStyle(color: ktext2white200),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide.none,
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     );
//   }
// }
