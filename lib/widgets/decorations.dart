  import 'package:flutter/material.dart';

///Für Eingabefelder in der App. Gibt die Dekoration für Eingabefelder zurück, wie z. B. Hintergrundfarbe, Rand und Platzhaltertext.
InputDecoration inputDecoration(String hintText,String? errorMessage) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: errorMessage!=null? Colors.red : Color(0xFFF5FCF9),
      contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0 * 1.5, vertical: 16.0),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }