import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onRefresh;
  const CustomAppBar({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true, // Ensures the title is centered
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min, // shrink to fit content
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG Logo
          SvgPicture.asset("assets/svg icons/logo.svg", width: 34, height: 30),
          const SizedBox(width: 8),
          // App Name
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "File",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Dock",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Ad",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     tooltip: "Refresh",

      //     onPressed: onRefresh,
      //     icon: Icon(Icons.refresh, color: Colors.white, size: 30),
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
