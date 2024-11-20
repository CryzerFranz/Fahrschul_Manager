import 'dart:ffi';

import 'package:fahrschul_manager/constants.dart';
import 'package:flutter/material.dart';

class Custom3DCard extends StatelessWidget {
  final String title;
  final Widget widget;
  final double width;

  Custom3DCard({required this.title, required this.widget, this.width = 0.9});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [mainColor, mainColor, mainColorComplementaryFirst]),
          // color: mainColor, // Background color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5), // Creates the 3D shadow effect
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and description
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            widget
          ],
        ),
      ),
    );
  }
}
