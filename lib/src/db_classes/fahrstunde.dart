import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_event.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschueler.dart';
import 'package:fahrschul_manager/src/db_classes/fahrzeug.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:fahrschul_manager/src/utils/date.dart';
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

Future<List<ParseObject>> retrieveUpcomingFahrstunden() async {
  try {
    final query = QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
      ..whereEqualTo("Fahrlehrer", Benutzer().dbUser!.objectId)
      ..whereGreaterThan('Datum', DateTime.now())
      ..orderByAscending('Datum')
      ..includeObject(['Fahrzeug', 'Fahrschueler'])
      ..setLimit(5);

    // Execute the query
    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      return response.results as List<ParseObject>;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

Future<bool> registerUserToFahrstunde(
    {required String id}) async {
      try{
  ParseObject? eventObject = await fetchFahrstundeById(eventId: id);
  if (eventObject == null) {
    throw ("fetching event failed");
  }

  eventObject.set("Fahrschueler", Benutzer().dbUser);
  eventObject.set("Freigeben", false);
  eventObject.set('UpdatedGesamtStd', false);


  final response = await eventObject.save();
  if (!response.success) {
    return false;
  }
  return true;
      }catch(e)
      {
        throw("Network error");
      }
}

/// Daten ändern eines existierenden Fahrstunde.
/// Es handelt sich hierbei um eine Änderungen eines Eintrags in der Tabelle/Klasse `Fahrstunden`
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
  else
  {
    eventObject.set('UpdatedGesamtStd', false);

  }
  eventObject.set("Fahrzeug", event.fahrzeug);
  eventObject.set("Fahrschueler", event.fahrschueler);
  eventObject.set("Titel", event.titel);
  eventObject.set("Beschreibung", event.description);
  eventObject.set("Datum", event.fullDate);
  eventObject.set("EndDatum", event.fullEndDate);
  eventObject.set("Freigeben", event.release);


  final response = await eventObject.save();
  if (!response.success) {
    return null;
  }
  return createEventData(
      release: event.release,
      eventId: response.results!.first.objectId,
      title: event.titel,
      description: event.description,
      date: event.fullDate,
      endDate: event.fullEndDate,
      fahrzeug: event.fahrzeug,
      fahrschueler: event.fahrschueler);
}

//TODO !!FRONTEND sollte überprüfen das enddatum nicht kleiner als datum ist.!!
/// Fügt eine Fahrstunde/Termin in die Datenbank ein und erstellt zugleich einen Objekt für das Kalendar Widget.
///
/// ### Return value:
/// - **[FahrstundenEvent]**
Future<FahrstundenEvent> addFahrstunde({
  required DateTime date,
  required DateTime endDate,
  required String title,
  bool release = false,
  ParseObject? fahrzeug,
  DateTime? pufferZeit,
  ParseObject? fahrschueler,
  String? description,
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
    ..set('Titel', title)
    ..set('Freigeben', release)
    ..set("Datum", date);

  if (fahrzeug != null) {
    termin.set("Fahrzeug", fahrzeug);
  }
  if (description != null) {
    termin.set("Beschreibung", description);
  }

  DateTime dbEndDate = endDate;
  if (pufferZeit != null) {
    dbEndDate = endDate.add(Duration(minutes: pufferZeit.minute));
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
      release: release,
      eventId: response.results!.first.objectId,
      title: title,
      description: description,
      date: date,
      endDate: endDate,
      fahrzeug: fahrzeug,
      fahrschueler: fahrschueler);
}

/// Wandelt die gegebenen Daten zu einem [FahrstundenEvent] um und gibt sie zurück.
///
/// ### Return value:
/// - **[FahrstundenEvent]**
FahrstundenEvent createEventData({
  required String eventId,
  required String title,
  required DateTime date,
  required DateTime endDate,
  bool release = false,
  String? description,
  ParseObject? fahrzeug,
  ParseObject? fahrschueler,
}) {
  late Color tileColor;
  if (release) {
    tileColor = tabBarRedShade300;
  } else {
    if (fahrzeug != null && fahrschueler != null) {
      tileColor = mainColor;
    } else if (fahrzeug != null && fahrschueler == null) {
      tileColor = mainColorComplementaryFirst;
    } else if (fahrzeug == null && fahrschueler != null) {
      tileColor = mainColorComplementarySecond;
    }
  }

  return FahrstundenEvent(
    release:  release,
      eventID: eventId,
      fahrzeug: fahrzeug,
      fahrschueler: fahrschueler,
      title: title,
      date: date,
      description: description,
      endDate: endDate,
      startTime: DateTime(
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
      ),
      endTime: DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        endDate.hour,
        endDate.minute,
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
    if (result.get<ParseObject?>("Fahrzeug") == null &&
        result.get<ParseObject?>("Fahrschueler") == null && result.get<bool>('Freigeben') == false) {
      await result.delete();
    } else {
      events.add(createEventData(
          release: result.get<bool>('Freigeben')!,
          eventId: result.objectId!,
          title: result.get<String>("Titel")!,
          date: result.get<DateTime>("Datum")!,
          endDate: result.get<DateTime>("EndDatum")!,
          description: result.get<String?>("Beschreibung"),
          fahrschueler: result.get<ParseObject?>("Fahrschueler"),
          fahrzeug: result.get<ParseObject?>("Fahrzeug")));
    }
  }
  return events;
}

/// Ein Stream der Periodisch alle 5 Sekunden `getUserFahrstunden` aufruft.
Stream<List<FahrstundenEvent>> getUserFahrstundenStream() async* {
  // initital fetch
  yield await getUserFahrstunden();

  // Regelmäßige Aktualisierungen nach dem ersten Abruf starten
  yield* Stream.periodic(const Duration(seconds: 5), (_) => getUserFahrstunden())
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
  availableFahrzeuge.addAll(
      await fetchAvailableFahrzeugExcludingIds(unavailableFahrzeugeIds));
  availableSchueler =
      await fetchAvailableFahrschuelerExcludingIds(unavailableSchuelerIds);

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

Future<List<ParseObject>> fetchFahrstundenFromFahrlehrer() async {
  // Create the query for the Fahrstunde class using the given objectId
  if(Benutzer().dbUser!.get<ParseObject>("Fahrlehrer") == null)
  {
    return [];
  }
  final QueryBuilder<ParseObject> queryBuilder =
      QueryBuilder<ParseObject>(ParseObject('Fahrstunden'))
        ..whereEqualTo('Fahrlehrer', Benutzer().dbUser!.get<ParseObject>("Fahrlehrer")!.objectId!)
        ..whereEqualTo('Freigeben', true)
        ..whereGreaterThan('Datum', DateTime.now())
        ..orderByAscending('Datum'); // Filter by objectId

  final ParseResponse response = await queryBuilder.query();

  if (response.success && response.results != null) {
    return response.results as List<ParseObject>;
  }

  return [];
}

Stream<List<ParseObject>> fetchFahrstundenFromFahrlehrerStream() async* {
  // initital fetch
  yield await fetchFahrstundenFromFahrlehrer();

  // Regelmäßige Aktualisierungen nach dem ersten Abruf starten
  yield* Stream.periodic(const Duration(seconds: 1), (_) => fetchFahrstundenFromFahrlehrer())
      .asyncMap((future) => future);
}

class Fahrstunde {
  final DateTime date;
  final DateTime endDate;
  final ParseObject? fahrschueler;
  final ParseObject? fahrzeug;
  final String? eventId;

  // Constructor with required named parameters
  Fahrstunde({
    required this.date,
    required this.endDate,
    this.fahrschueler,
    this.fahrzeug,
    this.eventId,
  });

  // Optional: Add a method to calculate the difference between the two DateTimes
  Duration get duration => endDate.difference(date);

  String dateToString() {
    return "${date.day}.${date.month}.${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String endDateToString() {
    return "${endDate.day}.${endDate.month}.${endDate.year} - ${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}";
  }

  // Map<String, String> getDateAndTimeSummery()
  // {
  //   return generateDateTimeSummary(date: date, endDate: endDate, startTime: date, endTime: endDate);
  // }

  String getDateRange() {
    return generateDateRangeText(start: date, end: endDate);
  }

  String getTimeRange() {
    return generateTimeRangeText(start: date, end: endDate);
  }

  String getFahrzeug() {
    if (fahrzeug == null) {
      return "-";
    }
    return "${fahrzeug!.get<ParseObject>("Marke")!.get<String>("Name")} (${fahrzeug!.get<String>("Label")})";
  }

  String getFahrschueler() {
    if (fahrschueler == null) {
      return "-";
    }
    return "${fahrschueler!.get<String>("Name")}, ${fahrschueler!.get<String>("Vorname")}";
  }

  @override
  String toString() {
    return 'Start: \$startDateTime, End: \$endDateTime, Duration: \${duration.inHours} hours';
  }
}
