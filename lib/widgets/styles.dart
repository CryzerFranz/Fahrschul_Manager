  import 'package:fahrschul_manager/constants.dart';
import 'package:flutter/material.dart';

///Für Eingabefelder in der App. Gibt die Dekoration für Eingabefelder zurück, wie z. B. Hintergrundfarbe, Rand und Platzhaltertext.
InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Color(0xFFF5FCF9),
      contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0 * 1.5, vertical: 16.0),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }


ButtonStyle stadiumButtonStyle({Color background = mainColor, Color foreground = Colors.white})
{
  return ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: background,
                            foregroundColor: foreground,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          );
}