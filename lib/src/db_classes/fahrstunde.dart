import 'package:calendar_view/calendar_view.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

//TODO !!FRONTEND sollte überprüfen das enddatum nicht kleiner als datum ist.!!
Future<void> addFahrstunde(
  DateTime datum,
  DateTime endDatum,
  String titel, {
  ParseObject? fahrzeug,
  DateTime? pufferZeit,
  ParseObject? fahrschueler,
  String? beschreibung,
}) async {
  if (!Benutzer().isFahrlehrer!) {
    throw ("No permission");
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
}

Future<List<CalendarEventData>> getUserFahrstunden() async {
  List<CalendarEventData> events = [];
  String role = Benutzer().isFahrlehrer! ? "Fahrlehrer" : "Fahrschueler";
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
        ..whereGreaterThan("Datum", DateTime.now())
        ..whereContains(role, Benutzer().dbUser!.objectId!);

  final apiResponse = await parseQuery.query();
  if (!apiResponse.success) {
    throw ("API Response failed. Check Network connection.");
  }

  if (apiResponse.results == null) {
    return [];
  }

  for (var result in apiResponse.results!) {
    CalendarEventData event;
    DateTime? endDate = result.get<DateTime?>("EndDatum") as DateTime?;

    event = CalendarEventData(
        title: result.get<String>("Titel"),
        date: result.get<DateTime>("Datum"),
        description: result.get<String?>("Beschreibung"),
        endDate: endDate,
        startTime: DateTime(
          result.get<DateTime>("Datum").year,
          result.get<DateTime>("Datum").month,
          result.get<DateTime>("Datum").day,
          result.get<DateTime>("Datum").hour,
          result.get<DateTime>("Datum").minute,
        ),
         endTime: DateTime(
          result.get<DateTime>("EndDatum").year,
          result.get<DateTime>("EndDatum").month,
          result.get<DateTime>("EndDatum").day,
          result.get<DateTime>("EndDatum").hour,
          result.get<DateTime>("EndDatum").minute,
        )
    );

    events.add(event);
  }
  return events;
}
