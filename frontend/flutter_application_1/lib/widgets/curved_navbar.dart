import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class TazamaNavBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  final bool isDarkMode;
  final bool showOnlyHome;

  const TazamaNavBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.isDarkMode,
    this.showOnlyHome = false,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor = isDarkMode ? const Color(0xFF1565C0) : Colors.white;
    Color background = Colors.blue;
    Color iconColor = isDarkMode ? Colors.white : Colors.blue;

    return CurvedNavigationBar(
      index: index,
      height: 60,
      backgroundColor: Colors.transparent,
      color: background,
      buttonBackgroundColor: activeColor,
      animationDuration: const Duration(milliseconds: 300),
      onTap: onTap,
      items: [
        if (showOnlyHome)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, color: iconColor),
              Text(
                "Home",
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
