import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Logo Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryColor, width: 2),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppTheme.primaryColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diskly',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 28,
                              ),
                        ),
                        const Text(
                          'v1.0.0',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Support & Connect
              const Text(
                'Support & Connect',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSocialIcon(Icons.camera_alt_outlined,"https://www.youtube.com/channel/UCdILqDNQwXY1N5eakpDBBjw"), // Instagram placeholder
                  _buildSocialIcon(Icons.play_circle_outline,"https://www.youtube.com/channel/UCdILqDNQwXY1N5eakpDBBjw"), // Youtube placeholder
                  _buildSocialIcon(Icons.telegram,"https://t.me/DisklyFileUploader_Bot"), // Telegram placeholder
                  _buildSocialIcon(Icons.discord,"https://www.youtube.com/channel/UCdILqDNQwXY1N5eakpDBBjw"), // Discord placeholder
                ],
              ),
              const SizedBox(height: 32),

              // Settings List
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.send_outlined,
                      title: 'Telegram Support',
                      subtitle: '@DisklySupport',
                      subtitleColor: AppTheme.primaryColor,link: "https://diskly.in/contact"
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: 'Privacy Policy',link: "https://diskly.in/privacy-policy"
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',link: "https://diskly.in/terms-and-condition"
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.share_outlined,
                      title: 'Share App',link: "https://play.google.com/store/apps/details?id=com.starwish.diskly"
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.star_border,
                      title: 'Rate Us',link: "https://play.google.com/store/apps/details?id=com.starwish.diskly"
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon,String link) {
    return InkWell(
      onTap:() async {
        final Uri _url = Uri.parse(link);
        if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
        }
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 28),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required String link,
  }) {
    return ListTile(
      onTap:() async {
        final Uri _url = Uri.parse(link);
        if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
        }

      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: subtitleColor ?? AppTheme.textSecondary),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.backgroundColor.withOpacity(0.5),
      indent: 24,
      endIndent: 24,
    );
  }
}
