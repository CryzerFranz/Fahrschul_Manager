import 'package:fahrschul_manager/constants.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int selectedIndex = 0; // Track the selected icon's index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Other content of the page
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 70,
                decoration: BoxDecoration(
                  color: navBarBackgroundColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 20),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavBarIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedIndex == index ? navBarSelectedColor : navBarUnSelectedColor,
        // Lighter color for selected, darker for unselected
      ),
      onPressed: () {
        setState(() {
          selectedIndex = index; // Update the selected index
        });
      },
    );
  }
}