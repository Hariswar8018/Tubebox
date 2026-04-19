import 'package:file_dock/controllers/security_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constant/colors.dart';
import '../widget/custom_app_bar.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(SecurityController());

    return Scaffold(
      backgroundColor: kbg1black500,
      appBar: const CustomAppBar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/register_bg.jpg"),
            fit: BoxFit.cover,
            opacity: 0.25,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Change Email Section
              Text(
                "Change Email",
                style: TextStyle(
                  color: kwhite,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _labeledField(
                "Old Email",
                controller.oldEmailController,
                false,
                hint: "Enter old email",
              ),
              const SizedBox(height: 12),
              _labeledField(
                "New Email",
                controller.newEmailController,
                false,
                hint: "Enter email",
              ),
              const SizedBox(height: 12),
              Obx(
                () => _labeledField(
                  "Current Password",
                  controller.currentPasswordController,
                  controller.showCurrentPassword.value,
                  isPassword: true,
                  hint: "Enter password",
                  onToggle: controller.toggleCurrentPassword,
                ),
              ),
              const SizedBox(height: 16),
              _customButton(
                "Update Email",
                onTap: () {
                  // TODO: Hook with controller
                  controller.updateEmail();
                  //controller.updateEmailWithNewAccount();
                },
              ),
              const SizedBox(height: 30),

              // Change Password Section
              Text(
                "Change Password",
                style: TextStyle(
                  color: kwhite,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => _labeledField(
                  "Old Password",
                  controller.oldPasswordController,
                  controller.showOldPassword.value,
                  isPassword: true,
                  hint: "Enter old password",
                  onToggle: controller.toggleOldPassword,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => _labeledField(
                  "New Password",
                  controller.newPasswordController,
                  controller.showNewPassword.value,
                  isPassword: true,
                  hint: "Enter new password",
                  onToggle: controller.toggleNewPassword,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => _labeledField(
                  "Confirm Password",
                  controller.confirmPasswordController,
                  controller.showConfirmPassword.value,
                  isPassword: true,
                  hint: "Enter confirm password",
                  onToggle: controller.toggleConfirmPassword,
                ),
              ),
              const SizedBox(height: 16),
              _customButton(
                "Update Password",
                onTap: () {
                  // TODO: Hook with controller
                  controller.updatePassword();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Labeled textfield (Title + TextField with hint)
  Widget _labeledField(
    String label,
    TextEditingController controller,
    bool obscure, {
    bool isPassword = false,
    String? hint,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: kwhite,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword ? !obscure : false,
          style: TextStyle(color: kwhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: ktext2white200),
            filled: true,
            fillColor: kbg2lightblack300,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: Colors.white70,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _customButton(String text, {required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kblueaccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
