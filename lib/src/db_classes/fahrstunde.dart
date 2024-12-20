import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_event.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschueler.dart';
import 'package:fahrschul_manager/src/db_classes/fahrzeug.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<ParseObject?> fetchFahrstundeById({required String eventId}) async {
  // Create the query for the Fahrstunde class using the given objectId
  final QueryBuilder<ParseObject> queryBuilder =
      QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
        ..whereEqualTo('objectId', eventId); // Filter by objectId

  // Execute the query
  final ParseResponse response = await queryBuilder.query();

  // Check for success and return the first (and should be only) result
  if (response.success && response.results != null) {
    return response.results!.first as ParseObject;
  }

  // Return null if no result or if the query failed
  return null;
}

Future<FahrstundenEvent?> updateFahrstunde(
    {required ExecuteChangeCalendarEventData event}) async {
  if (event.eventId == null) {
    throw ("Event not exisiting");
  }
  ParseObject? eventObject = await fetchFahrstundeById(eventId: event.eventId!);
  if (eventObject == null) {
    throw ("fetching event failed");
  }

  if (event.fahrschueler == null) {
    // Wenn kein Fahrschueler ausgewählt ist wird 'UpdatedGesantStd' auf 'true' gesetzt damit
    // dieser Eintrag nicht vom Schedule Job erfasst wird.
    eventObject.set("UpdatedGesamtStd", true);
  }
  eventObject.set("Fahrzeug", event.fahrzeuge);
  eventObject.set("Fahrschueler", event.fahrschueler);
  eventObject.set("Titel", event.titel);
  eventObject.set("Beschreibung", event.description);
  eventObject.set("Datum", event.fullDate);
  eventObject.set("EndDatum", event.fullEndDate);

  final response = await eventObject.save();
  if (!response.success) {
    return null;
  }
  return createEventData(
      eventId: response.results!.first.objectId,
      titel: event.titel,
      beschreibung: event.description,
      datum: event.fullDate,
      endDatum: event.fullEndDate,
      fahrzeug: event.fahrzeuge,
      fahrschueler: event.fahrschueler);
}

//TODO !!FRONTEND sollte überprüfen das enddatum nicht kleiner als datum ist.!!
/// Fügt eine Fahrstunde/Termin in die Datenbank ein und erstellt zugleich einen Objekt für das Kalendar Widget.
///
/// ### Return value:
/// - **[FahrstundenEvent]**
Future<FahrstundenEvent> addFahrstunde({
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
  } else {
    // Wenn kein Fahrschueler ausgewählt ist wird 'UpdatedGesantStd' auf 'true' gesetzt damit
    // dieser Eintrag nicht vom Schedule Job erfasst wird.
    termin.set('UpdatedGesamtStd', true);
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
      fahrschueler: fahrschueler,
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

  DateTime today = DateTime.now(); // Get today's date
  int currentWeekday = today.weekday; // 1 = Monday, 7 = Sunday

  // Calculate the date for the current Monday
  DateTime currentMonday = today.subtract(Duration(days: currentWeekday - 1));

  String role = Benutzer().isFahrlehrer! ? "Fahrlehrer" : "Fahrschueler";
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
        ..whereGreaterThan("Datum", currentMonday)
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
  yield* Stream.periodic(Duration(seconds: 5), (_) => getUserFahrstunden())
      .asyncMap((future) => future);
}

/// Ruft verfügbare Ressourcen (Fahrzeuge und Fahrschüler) innerhalb eines angegebenen Datumsbereichs ab.
///
/// Diese Funktion sucht "Fahrstunden" (Fahrstunden-Einträge) für einen bestimmten Fahrlehrer
/// im angegebenen Zeitraum (Start- und Enddatum). Sie ermittelt nicht verfügbare Fahrzeuge
/// und Fahrschüler basierend auf den Fahrstunden und schließt diese von den verfügbaren Listen aus.
///
/// Es wird eine Map zurückgegeben, die Listen der verfügbaren Fahrzeuge und Fahrschüler enthält.
///
/// ### Parameter:
/// - [start]: Das Startdatum des Zeitraums.
/// - [end]: Das Enddatum des Zeitraums.
///
/// ### Return value:
/// - Eine **[Map<String, List<ParseObject>>]** mit zwei Schlüsseln:
///   - `"Fahrzeuge"`: Liste der verfügbaren Fahrzeuge.
///   - `"Schueler"`: Liste der verfügbaren Fahrschüler.
Future<Map<String, List<ParseObject>>> fetchAvailableResourcesInRange(
    {required DateTime start, required DateTime end}) async {
  List<String> unavailableFahrzeugeIds = [];
  List<String> unavailableSchuelerIds = [];
  List<ParseObject> availableFahrzeuge = [];
  List<ParseObject> availableSchueler = [];
  //TODO brauche alle fahrstunden der Fahrschule ------> TO TEST
  final List<ParseObject> fahrlehrerList =
      await fetchAllFahrlehrerFromFahrschule(Benutzer().fahrschule!.objectId!);
  final QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
        ..whereContainedIn("Fahrlehrer", fahrlehrerList)
        ..whereLessThanOrEqualTo(
            "Datum", end) // Event starts before or on the end date
        ..whereGreaterThanOrEqualsTo("EndDatum", start)
        ..excludeKeys([
          "ObjectId",
          "Fahrlehrer",
          "Datum",
          "EndDatum",
          "Titel",
          "Beschreibung"
        ])
        ..includeObject(
            ["Fahrzeug", "Fahrschueler"]); // Include the related objects
  // EndDatum >= start

  // Execute the query
  final ParseResponse response = await query.query();

  // Check for success and return results
  if (response.success && response.results != null) {
    for (var entry in response.results as List<ParseObject>) {
      if (entry.get<ParseObject>("Fahrzeug") != null) {
        unavailableFahrzeugeIds
            .add(entry.get<ParseObject>("Fahrzeug")!.objectId!);
      }
      if (entry.get<ParseObject>("Fahrschueler") != null) {
        unavailableSchuelerIds
            .add(entry.get<ParseObject>("Fahrschueler")!.objectId!);
      }
      //availableFahrzeuge.addAll(await fetchAvailableFahrzeugExcludingIds(unavailableFahrzeugeIds));
      //availableSchueler = await fetchAvailableFahrschuelerExcludingIds(unavailableSchuelerIds);
    }
    Set<String> seenFahrzeug = {};
    Set<String> seenFahrschueler = {};
    unavailableFahrzeugeIds = unavailableFahrzeugeIds
        .where((item) => seenFahrzeug.add(item))
        .toList();
    unavailableSchuelerIds = unavailableSchuelerIds
        .where((item) => seenFahrschueler.add(item))
        .toList();
  }
  availableFahrzeuge.addAll(await fetchAvailableFahrzeugExcludingIds(unavailableFahrzeugeIds));
  availableSchueler = await fetchAvailableFahrschuelerExcludingIds(unavailableSchuelerIds);

  return {
    "Fahrzeuge": availableFahrzeuge,
    "Schueler": availableSchueler,
  };
}

List<ParseObject> getUniqueObjectsByField(
    List<ParseObject> objects, String fieldName) {
  Set<dynamic> seenValues = {};
  return objects
      .where((object) => seenValues.add(object.get(fieldName)))
      .toList();
}
