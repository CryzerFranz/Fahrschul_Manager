import 'package:fahrschul_manager/constants.dart';
import 'package:flutter/material.dart';

/// Diese Klasse eignet sich für die Darstellung von Karten mit unterschiedlichen Inhalten und bietet ein modernes, responsives Design.
class Custom3DCard extends StatelessWidget {
  final String? title;
  final Widget widget;
  final double width;
  final List<Color> colors;

  Custom3DCard(
      {required this.widget,
      this.title,
      this.width = 0.9,
      this.colors = const [mainColor, mainColor, mainColorComplementaryFirst]});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            widget,
          ],
        ),
      ),
    );
  }
}
