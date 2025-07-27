import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tubebox/admin/all.dart';
import 'package:tubebox/main.dart';
import 'package:tubebox/settings/add_video.dart';

class Profile extends StatelessWidget {
 Profile({super.key});

  final String privacyPolicy = '''
Privacy Policy
Effective Date: 2024-2025

Introduction
TubeBox.in (the Mobile App), a video playing app. This Privacy Policy explains how we collect, use, disclose, and protect user information.

Information Collection
1. Personal Information: We collect: Email address (optional)
   - Device information (e.g., model, operating system)
2. Non-Personal Information: We collect:
   - Video viewing history
   - Search queries

Information Use
1. Provide App functionality
2. Improve video recommendations
3. Personalize user experience
4. Communicate updates and promotions

Information Disclosure
1. Third-party video content providers 
2. Advertising partners

Data Security
We implement reasonable security measures to protect user information.

User Rights
1. Access
2. Correction
3. Deletion
4. Opt-out

Children's Privacy
Watch Box is intended for users 13 and older. We comply with COPPA regulations.

California Consumer Privacy Act (CCPA)
Users have the right to request data deletion, opt-out of data sale, and access their data.

EU General Data Protection Regulation (GDPR)
Users have the right to data access, rectification, erasure, restriction, objection, and data portability.

Changes
We reserve the right to update this Privacy Policy.

Contacts & support
www.tubebox.in
tubeboxhelp@gmail.com

Additional Information
By using TubeBox, you agree to our Terms of Service and this Privacy Policy.

To comply with laws, consider adding:
1. A "Do Not Sell My Personal Information" link (CCPA) 
2. A GDPR-compliant cookie consent banner
3. COPPA-compliant parental consent for users under 13

Consult with a lawyer to ensure compliance with applicable laws.
''';

  bool admin=true;
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: isnight?Colors.black:bgcolor,
        body: admin?Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
                onTap: (){
                  Navigator.push(
                      context, PageTransition(
                      child: AddVideo(), type: PageTransitionType.rightToLeft, duration: Duration(milliseconds: 200)
                  ));
                },
                child: Center(child: StripedBorderContainer(width: w-30, height: h/3-20, str: 'Add Video', h: Icon(Icons.add),))),
            SizedBox(height: 50,),InkWell(
                onTap: (){
                  Navigator.push(
                      context, PageTransition(
                      child: All_Videos(), type: PageTransitionType.rightToLeft, duration: Duration(milliseconds: 200)
                  ));
                },
                child: Center(child: StripedBorderContainer(width: w-30, height: h/3-20, str: 'See Video', h: Icon(Icons.remove_red_eye),))),
          ],
        ):
        SingleChildScrollView(
          padding:  EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
              style:  TextStyle(fontSize: 16, color: Colors.black),
              children: [
                 TextSpan(text: 'Effective Date: 2024-2025\n\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),),
                TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: 'Introduction\nTubeBox.in (the Mobile App) is a video playing app. This Privacy Policy explains how we collect, use, disclose, and protect user information.\n\n'),
                 TextSpan(text: 'Information Collection\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),),
                TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: '1. Personal Information: We collect email address (optional) and device information (e.g., model, operating system).\n'),
                TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: '2. Non-Personal Information: We collect video viewing history and search queries.\n\n'),
                // Example of an important point styled in bold red:
                 TextSpan(
                  text: 'Important: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),
                  text: 'Ensure that you review all the permissions requested by the app carefully.',
                ),
                 TextSpan(text: '\n\n'),
                 TextSpan(style: TextStyle(
                   fontWeight: FontWeight.w400,
                   color:!isnight?Colors.black:Colors.white,
                 ),text: 'Information Use\n- Provide App functionality\n- Improve video recommendations\n- Personalize user experience\n- Communicate updates and promotions\n\n'),
                 TextSpan(style: TextStyle(
                   fontWeight: FontWeight.w400,
                   color:!isnight?Colors.black:Colors.white,
                 ),text: 'Information Disclosure\n- Third-party video content providers\n- Advertising partners\n\n'),
                 TextSpan(style: TextStyle(
                   fontWeight: FontWeight.w400,
                   color:!isnight?Colors.black:Colors.white,
                 ),text: 'Data Security\nWe implement reasonable security measures to protect user information.\n\n'),
                 TextSpan(text: 'User Rights\n- Access\n- Correction\n- Deletion\n- Opt-out\n\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: "Children's Privacy\nWatch Box is intended for users 13 and older. We comply with COPPA regulations.\n\n"),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: 'California Consumer Privacy Act (CCPA)\nUsers have the right to request data deletion, opt-out of data sale, and access their data.\n\n'),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: 'EU General Data Protection Regulation (GDPR)\nUsers have the right to data access, rectification, erasure, restriction, objection, and data portability.\n\n'),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: 'Changes\nWe reserve the right to update this Privacy Policy.\n\n'),
                 TextSpan(text: 'Contacts & Support\nwww.tubebox.in\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),),
                 TextSpan(text: 'tubeboxhelp@gmail.com\n\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: 'Additional Information\nBy using TubeBox, you agree to our Terms of Service and this Privacy Policy.\n'),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: 'To comply with laws, consider adding:\n'),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: '- A "Do Not Sell My Personal Information" link (CCPA)\n'),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: '- A GDPR-compliant cookie consent banner\n'),
                 TextSpan(style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color:!isnight?Colors.black:Colors.white,
                ),text: '- COPPA-compliant parental consent for users under 13\n\n'),
                 TextSpan(text: 'Consult with a lawyer to ensure compliance with applicable laws.\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class StripedBorderContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderWidth;
  final double gapWidth;
  final Color borderColor;
  final String str;
  final Widget h;

  StripedBorderContainer({
   required this.width ,
   required this.height ,
    this.borderWidth = 4,
    this.gapWidth = 6,
    this.borderColor = Colors.blue,
    required this.str,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StripedBorderPainter(
        borderWidth: borderWidth,
        gapWidth: gapWidth,
        borderColor: borderColor,
      ),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            h,
            Text(
              str,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class StripedBorderPainter extends CustomPainter {
  final double borderWidth;
  final double gapWidth;
  final Color borderColor;

  StripedBorderPainter({
    required this.borderWidth,
    required this.gapWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final double totalWidth = borderWidth + gapWidth;

    // Draw top border with gaps
    for (double i = 0; i < size.width; i += totalWidth) {
      canvas.drawLine(Offset(i, 0), Offset(i + borderWidth, 0), paint);
    }

    // Draw bottom border with gaps
    for (double i = 0; i < size.width; i += totalWidth) {
      canvas.drawLine(Offset(i, size.height), Offset(i + borderWidth, size.height), paint);
    }

    // Draw left border with gaps
    for (double i = 0; i < size.height; i += totalWidth) {
      canvas.drawLine(Offset(0, i), Offset(0, i + borderWidth), paint);
    }

    // Draw right border with gaps
    for (double i = 0; i < size.height; i += totalWidth) {
      canvas.drawLine(Offset(size.width, i), Offset(size.width, i + borderWidth), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}