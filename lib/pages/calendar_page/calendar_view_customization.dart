import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


/// Eine benutzerdefinierte Event-Klasse, die von [CalendarEventData] erbt, 
/// um zusätzliche Felder für ein Fahrzeug (`fahrzeug`) und einen Schüler (`schueler`) einzuschließen.
class FahrstundenEvent extends CalendarEventData<FahrstundenEvent> {
  final ParseObject? fahrzeug; 
  final ParseObject? schueler;
  final String eventID;

  FahrstundenEvent({
    required this.eventID,
    required super.title,
    required DateTime super.startTime,
    required DateTime super.endTime,
    required DateTime super.endDate,
    required super.date,
    super.description,
    this.fahrzeug,
    this.schueler,
    super.descriptionStyle,
    super.titleStyle,
    super.color,
  });
}
