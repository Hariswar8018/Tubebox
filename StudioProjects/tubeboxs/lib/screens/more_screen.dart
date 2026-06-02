import 'package:flutter/material.dart';
import 'package:tubeboxs/screens/premium_bottom_sheet.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _showPremiumBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tubeb',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.link, color: const Color(0xFF10B981), size: 48),
                const Text(
                  'X',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Best Cloud Storage and File Sharing Platform',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _showPremiumBottomSheet(context),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Color(0xFFFFD700),
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Go ADs Free. ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Subscribe to our Premium App.',
                                style: TextStyle(color: Color(0xFFD4AF37)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'and many more advantages...',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Show Details',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -15,
                    left: 30,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B6B3D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              'Join Us',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.discord, const Color(0xFF5865F2)),
                const SizedBox(width: 24),
                _buildSocialIcon(Icons.play_circle_fill, const Color(0xFFFF0000)),
                const SizedBox(width: 24),
                _buildSocialIcon(Icons.camera_alt, const Color(0xFFE1306C)), // Instagram placeholder
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'v21.3',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 6),
            const Text(
              'TUBEBOX 2026 @ All Rights Reserved',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Icon(icon, color: color, size: 40);
  }
}
