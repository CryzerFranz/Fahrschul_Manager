import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

//TODO !!FRONTEND sollte überprüfen das enddatum nicht kleiner als datum ist.!!
/// Fügt eine Fahrstunde/Termin in die Datenbank ein und erstellt zugleich einen Objekt für das Kalendar Widget.
///
/// ### Return value:
/// - **[CalendarEventData]**
Future<CalendarEventData> addFahrstunde({
  required DateTime datum,
  required DateTime endDatum,
  required String titel,
  ParseObject? fahrzeug,
  DateTime? pufferZeit,
  ParseObject? fahrschueler,
  String? beschreibung,
}) async {
  if (!Benutzer().isFahrlehrer!) {
    throw ("No permission");
  }
  if (fahrzeug == null && fahrschueler == null) {
    throw ("Fahrzeug or Fahrschueler has to be at least choosed");
  }
  // Event in die Datenbank abspeichern
  //DateTime dbDate = datum.add(Duration(hours: zeit.hour, minutes: zeit.minute));

  final termin = ParseObject("Fahrstunden")
    ..set('Fahrlehrer', Benutzer().dbUser)
    ..set('Titel', titel)
    ..set("Datum", datum);

  if (fahrzeug != null) {
    termin.set("Fahrzeug", fahrzeug);
  }
  if (beschreibung != null) {
    termin.set("Beschreibung", beschreibung);
  }

  DateTime dbEndDate = endDatum;
  if (pufferZeit != null) {
    dbEndDate = endDatum.add(Duration(minutes: pufferZeit.minute));
  }
  termin.set("EndDatum", dbEndDate);

  if (fahrschueler != null) {
    termin.set('Fahrschueler', fahrschueler);
  }

  final ParseResponse response = await termin.save();
  if (!response.success) {
    throw Exception(response.error?.message);
  }

  // Event erstellen für calender_view package
  return createEventData(
      eventId: response.results!.first.objectId,
      titel: titel,
      beschreibung: beschreibung,
      datum: datum,
      endDatum: endDatum,
      fahrzeug: fahrzeug,
      fahrschueler: fahrschueler);
}

//TODO evtl async?
/// Wandelt die gegebenen Daten zu einem [FahrstundenEvent] um und gibt sie zurück.
///
/// ### Return value:
/// - **[FahrstundenEvent]**
FahrstundenEvent createEventData({
  required String eventId,
  required String titel,
  required DateTime datum,
  required DateTime endDatum,
  String? beschreibung,
  ParseObject? fahrzeug,
  ParseObject? fahrschueler,
}) {
  late Color tileColor;
  if (fahrzeug != null && fahrschueler != null) {
    tileColor = mainColor;
  } else if (fahrzeug != null && fahrschueler == null) {
    tileColor = mainColorComplementaryFirst;
  } else if (fahrzeug == null && fahrschueler != null) {
    tileColor = mainColorComplementarySecond;
  }

  return FahrstundenEvent(
      eventID: eventId,
      fahrzeug: fahrzeug,
      schueler: fahrschueler,
      title: titel,
      date: datum,
      description: beschreibung,
      endDate: endDatum,
      startTime: DateTime(
        datum.year,
        datum.month,
        datum.day,
        datum.hour,
        datum.minute,
      ),
      endTime: DateTime(
        endDatum.year,
        endDatum.month,
        endDatum.day,
        endDatum.hour,
        endDatum.minute,
      ),
      color: tileColor,
      titleStyle: const TextStyle(
          fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
      descriptionStyle: const TextStyle(
          fontSize: 12, color: Colors.white, fontWeight: FontWeight.w400));
}

/// Gibt alle Termine des Eingeloggten Benutzers zurück.
///
/// ### Return value:
/// - **[List<CalendarEventData>]**
Future<List<FahrstundenEvent>> getUserFahrstunden() async {
  List<FahrstundenEvent> events = [];
  String role = Benutzer().isFahrlehrer! ? "Fahrlehrer" : "Fahrschueler";
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
        ..whereGreaterThan("Datum", DateTime.now())
        ..whereContains(role, Benutzer().dbUser!.objectId!)
        ..includeObject(["Fahrzeug", "Fahrzeug.Marke", "Fahrschueler"]);

  final apiResponse = await parseQuery.query();
  if (!apiResponse.success) {
    throw ("API Response failed. Check Network connection.");
  }

  if (apiResponse.results == null) {
    return [];
  }

  for (ParseObject result in apiResponse.results!) {
    events.add(createEventData(
        eventId: result.objectId!,
        titel: result.get<String>("Titel")!,
        datum: result.get<DateTime>("Datum")!,
        endDatum: result.get<DateTime>("EndDatum")!,
        beschreibung: result.get<String?>("Beschreibung"),
        fahrschueler: result.get<ParseObject?>("Fahrschueler"),
        fahrzeug: result.get<ParseObject?>("Fahrzeug")));
  }
  return events;
}

/// Ein Stream der Periodisch alle 5 Sekunden `getUserFahrstunden` aufruft.
Stream<List<FahrstundenEvent>> getUserFahrstundenStream() async* {
  // initital fetch
  yield await getUserFahrstunden();

  // Regelmäßige Aktualisierungen nach dem ersten Abruf starten
  yield* Stream.periodic(Duration(seconds: 90000), (_) => getUserFahrstunden())
      .asyncMap((future) => future);
}

Future<List<ParseObject>> fetchFahrstundenInRange({required DateTime start, required DateTime end}) async
{
   final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
    ..whereContains("Fahrlehrer", Benutzer().dbUserId!)
    ..whereLessThanOrEqualTo("Datum", end) // Event starts before or on the end date
    ..whereGreaterThanOrEqualsTo("EndDatum", start)
    ..includeObject(["Fahrzeug", "Fahrschueler"]);  // EndDatum >= start

  // Execute the query
  final ParseResponse response = await query.query();

  // Check for success and return results
  if (response.success && response.results != null) {
    return response.results as List<ParseObject>;
  }

  // Return an empty list if there were no results or if the query failed
  return [];
}
