// import 'package:file_dock/screens/login_screen.dart';
// import 'package:file_dock/widget/custom_app_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../constant/colors.dart';
// import '../controllers/register_controller.dart';

// class RegisterScreen extends StatelessWidget {
//   RegisterScreen({super.key});

//   final RegisterController controller = Get.put(RegisterController());

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: const CustomAppBar(),
//         backgroundColor: kbg1black500,
//         body: Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/register_bg.jpg"),
//               fit: BoxFit.cover,
//               opacity: 0.25,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 60),

//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Form(
//                     key: controller.formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 131),

//                         /// Email
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
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: kbg2lightblack300,
//                             hintText: "Enter user name",
//                             hintStyle: TextStyle(color: ktext2white200),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 14,
//                             ),
//                           ),
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

//                         /// Password
//                         Text(
//                           "Password",
//                           style: TextStyle(
//                             color: ktext1white100,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 10),

//                         Obx(() => TextFormField(
//                           controller: controller.passwordController,
//                           style: TextStyle(color: kwhite),
//                           obscureText: controller.obscurePassword.value,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: kbg2lightblack300,
//                             hintText: "Enter password",
//                             hintStyle: TextStyle(color: ktext2white200),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 14,
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 controller.obscurePassword.value
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                                 color: ktext3white300,
//                               ),
//                               onPressed:
//                               controller.togglePasswordVisibility,
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Password is required";
//                             }
//                             if (value.length < 6) {
//                               return "Password must be at least 6 chars";
//                             }
//                             return null;
//                           },
//                         )),

//                         const SizedBox(height: 50),

//                         /// Register button
//                         Center(
//                           child: SizedBox(
//                             width: 220,
//                             height: 50,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: kblueaccent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                               ),
//                               onPressed: controller.registerUser,
//                               child: Text(
//                                 "Register",
//                                 style: TextStyle(
//                                   color: kblack,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 18,),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text('Already have an account',style: TextStyle(
//                               color: kwhite,
//                               fontSize: 16,
//                             ),),
//                             TextButton(onPressed: () {
//                               Get.to(() => LoginScreen());
//                             }, child: Text('Log in',style: TextStyle(
//                               color: kblueaccent,
//                               fontSize: 16,
//                             ),))
//                           ],
//                         )
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
// }
