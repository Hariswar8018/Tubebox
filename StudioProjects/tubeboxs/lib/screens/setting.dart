import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = true;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF10B981)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🌙 Theme Toggle
          _buildTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            trailing: Switch(
              value: isDarkMode,
              activeColor: const Color(0xFF10B981),
              onChanged: (val) {
                setState(() {
                  isDarkMode = val;
                });
              },
            ),
          ),

          const Divider(color: Colors.grey),

          /// 📥 Downloads
          _buildTile(
            icon: Icons.download,
            title: "My Downloads",
            onTap: () {
              // Navigate to Downloads Page (create later)
            },
          ),

          const Divider(color: Colors.grey),

          /// 🌐 Website
          _buildTile(
            icon: Icons.language,
            title: "Visit Our Website",
            onTap: () => _launchURL("https://yourwebsite.com"),
          ),

          /// 🔐 Privacy Policy
          _buildTile(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () => _launchURL("https://yourwebsite.com/privacy"),
          ),

          /// 📜 Terms
          _buildTile(
            icon: Icons.description,
            title: "Terms & Conditions",
            onTap: () => _launchURL("https://yourwebsite.com/terms"),
          ),

          const Divider(color: Colors.grey),

          /// 💎 Premium Section
          _buildTile(
            icon: Icons.workspace_premium,
            title: "Buy Premium",
            onTap: () {
              // Integrate in-app purchase
            },
          ),

          _buildTile(
            icon: Icons.restore,
            title: "Restore Purchase",
            onTap: () {
              // Restore logic
            },
          ),

          const Divider(color: Colors.grey),

          /// 📧 Feedback
          _buildTile(
            icon: Icons.feedback,
            title: "Send Feedback",
            onTap: () => _launchURL("mailto:support@yourapp.com"),
          ),

          /// ℹ️ About
          _buildTile(
            icon: Icons.info,
            title: "About App",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "TubeBox",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2026 TubeBox Inc.",
              );
            },
          ),
        ],
      ),
    );
  }
}