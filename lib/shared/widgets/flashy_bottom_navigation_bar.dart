import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

class FlashyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  FlashyBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FlashyTabBar(
      selectedIndex: currentIndex,
      showElevation: true,
      onItemSelected: onTap,
      backgroundColor: Colors.white,
      items: [
        FlashyTabBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
        ),
        FlashyTabBarItem(
          icon: Icon(Icons.event),
          title: Text('Events'),
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
        ),
        FlashyTabBarItem(
          icon: Icon(Icons.person),
          title: Text('Profile'),
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
        ),
      ],
    );
  }
}