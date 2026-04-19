import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List<String> icons; // ✅ Now a list of SVG asset paths
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.icons,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> groups = [];

    // Group 1: before selected
    if (selectedIndex > 0) {
      groups.add(
        _buildGroup(start: 0, end: selectedIndex - 1, isSelectedGroup: false),
      );
    }

    // Group 2: selected
    groups.add(
      _buildGroup(
        start: selectedIndex,
        end: selectedIndex,
        isSelectedGroup: true,
      ),
    );

    // Group 3: after selected
    if (selectedIndex < icons.length - 1) {
      groups.add(
        _buildGroup(
          start: selectedIndex + 1,
          end: icons.length - 1,
          isSelectedGroup: false,
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: groups);
  }

  Widget _buildGroup({
    required int start,
    required int end,
    required bool isSelectedGroup,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isSelectedGroup ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSelectedGroup
            ? [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          for (int i = start; i <= end; i++)
            GestureDetector(
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: SvgPicture.asset(
                  icons[i],
                  height: 26,
                  width: 26,
                  colorFilter: ColorFilter.mode(
                    isSelectedGroup ? Colors.black : Colors.grey.shade700,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
