import 'package:fahrschul_manager/constants.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05, // 5% padding on left
        right: MediaQuery.of(context).size.width * 0.05, // 5% padding on right
        bottom: 40.0, // 10px bottom padding (adjust as needed)
      ), // 5% padding on both sides
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: navBarBackgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildNavBarIcon(Icons.chat_bubble_outline, 0),
            buildNavBarIcon(Icons.search, 1),
            buildNavBarIcon(Icons.timer, 2),
            buildNavBarIcon(Icons.notifications, 3),
            buildNavBarIcon(Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  Widget buildNavBarIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedIndex == index ? navBarSelectedColor : navBarUnSelectedColor,
      ),
      onPressed: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }
}
