import 'package:calendar_view/calendar_view.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

//TODO !!FRONTEND sollte überprüfen das enddatum nicht kleiner als datum ist.!!
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
  return createEventData(titel: titel, beschreibung: beschreibung, datum: datum, endDatum: endDatum);
}

CalendarEventData createEventData({
  required String titel,
  required DateTime datum,
  required DateTime endDatum,
  String? beschreibung,
}) {
  return CalendarEventData(
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
      ));
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
    events.add(createEventData(
        titel: result.get<String>("Titel"),
        datum: result.get<DateTime>("Datum"),
        endDatum: result.get<DateTime>("EndDatum"),
        beschreibung: result.get<String?>("Beschreibung")));
  }
  return events;
}
