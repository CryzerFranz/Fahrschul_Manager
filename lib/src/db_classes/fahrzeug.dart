import 'dart:async';

import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Fügt ein Fahrzeug zur Fahrschule hinzu
Future<bool> addFahrzeug(
    {required ParseObject getriebe,
    required ParseObject fahrzeugtyp,
    required ParseObject marke,
    String? label,
    bool anhaengerkupplung = false}) async {
  final fahrschuleObj = Benutzer().fahrschule;
  final user = Benutzer().parseUser;

  if (fahrschuleObj == null || user == null) {
    return false;
  }

  final fahrzeugObject = ParseObject("Fahrzeug")
    ..set('Getriebe', getriebe)
    ..set('Fahrzeugtyp', fahrzeugtyp)
    ..set('Marke', marke)
    ..set('Label', label)
    ..set('Anhaengerkupplung', anhaengerkupplung)
    ..set('Fahrschule', fahrschuleObj);

  final ParseResponse response = await fahrzeugObject.save();
  if (!response.success) {
    return false;
  }
  return true;
}

Future<bool> updateLabelFahrzeug(
    {required ParseObject fahrzeug, required String label}) async {
  try {
    fahrzeug.set('Label', label);
    final response = await fahrzeug.save();
    if (!response.success) {
      return false;
    }
    return true;
  } catch (e) {
    throw ("Network error");
  }
}

//TODO NUR ZUM TESTEN DA WAHRSCHEINLICH
Future<List<ParseObject>> fetchAvailableFahrzeugExcludingIds(
    List<String> ids) async {
  final QueryBuilder<ParseObject> queryBuilder =
      QueryBuilder<ParseObject>(ParseObject('Fahrzeug'))
        ..whereEqualTo("Fahrschule", Benutzer().fahrschule!.objectId!)
        ..whereNotContainedIn("objectId", ids)
        ..includeObject(['Getriebe', 'Marke']); // Include the related objects

  // Execute the query
  final ParseResponse apiResponse = await queryBuilder.query();

  // Check for success and return the first result
  if (apiResponse.success && apiResponse.results != null) {
    return apiResponse.results as List<ParseObject>;
  }

  // Return null if there were no results or if the query failed
  return [];
}

//TODO TEST
Future<List<ParseObject>> fetchAllFahrzeug(ParseObject fahrschule) async {
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Fahrzeug'))
        ..whereContains("Fahrschule", fahrschule.objectId!)
        ..includeObject(["Marke", "Getriebe", "Fahrzeugtyp"]);

  final apiResponse = await parseQuery.query();

  if (!apiResponse.success || apiResponse.results == null) {
    return [];
  }

  return apiResponse.results as List<ParseObject>;
}

Future<ParseObject?> fetchFahrzeugById(ParseObject fahrschule, String objectId) async {
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Fahrzeug'))
        ..whereContains("Fahrschule", fahrschule.objectId!)
        ..whereEqualTo("objectId", objectId)
        ..includeObject(["Marke", "Getriebe", "Fahrzeugtyp"]);

  final apiResponse = await parseQuery.query();

  if (!apiResponse.success || apiResponse.results == null) {
    return null;
  }

  return apiResponse.results!.first as ParseObject;
}

/// Gibt alle arten von Getriebe von der Datenbank zurück.
///
/// ### Return value:
/// - **[List<ParseObject>]**
Future<List<ParseObject>> fetchAllGetriebe() async {
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Getriebe'));

  final apiResponse = await parseQuery.query();

  if (!apiResponse.success || apiResponse.results == null) {
    return [];
  }

  return apiResponse.results as List<ParseObject>;
}

/// Gibt alle arten von Marken von der Datenbank zurück.
///
/// ### Return value:
/// - **[List<ParseObject>]**
Future<List<ParseObject>> fetchAllMarke() async {
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Marke'));

  final apiResponse = await parseQuery.query();

  if (!apiResponse.success || apiResponse.results == null) {
    return [];
  }

  return apiResponse.results as List<ParseObject>;
}

/// Gibt alle arten von Fahrzeugtypen von der Datenbank zurück.
///
/// ### Return value:
/// - **[List<ParseObject>]**
Future<List<ParseObject>> fetchAllFahrzeugtyp() async {
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Fahrzeugtyp'));

  final apiResponse = await parseQuery.query();

  if (!apiResponse.success || apiResponse.results == null) {
    return [];
  }

  return apiResponse.results as List<ParseObject>;
}

//TODO Wahrscheinlich danach nicht mehr nötig

/// Erhalte einen ParseObject von `Getriebe`.
///
/// ### Parameters:
///
/// - **`String` [typ]** : Bezeichnung des Getriebes.
///
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
///
/// ### Exception:
/// - **[Exception]**
Future<ParseObject?> getGetriebeByTyp(final String typ) async {
  try {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Getriebe'))
          ..whereContains('Typ', typ);

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message);
    }
    if (apiResponse.results == null || apiResponse.results!.isEmpty) {
      return null;
    }

    return apiResponse.results!.first as ParseObject;
  } catch (e) {
    throw Exception("Error: getGetriebe -> $e");
  }
}

/// Erhalte einen ParseObject von `Marke`.
///
/// ### Parameters:
///
/// - **`String` [name]** : Name der Marke.
///
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
///
/// ### Exception:
/// - **[Exception]**
Future<ParseObject?> getMarkeByTyp(final String name) async {
  try {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Marke'))
          ..whereContains('Name', name);

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message);
    }
    if (apiResponse.results == null || apiResponse.results!.isEmpty) {
      return null;
    }

    return apiResponse.results!.first as ParseObject;
  } catch (e) {
    throw Exception("Error: getMarke -> $e");
  }
}

/// Erhalte einen ParseObject von `Fahrzeugtyp`.
///
/// ### Parameters:
///
/// - **`String` [typ]** : Bezeichnung des Fahrzeugtyps.
///
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
///
/// ### Exception:
/// - **[Exception]**
Future<ParseObject?> getFahrzeugtypByTyp(final String typ) async {
  try {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Fahrzeugtyp'))
          ..whereContains('Typ', typ);

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message);
    }
    if (apiResponse.results == null || apiResponse.results!.isEmpty) {
      return null;
    }

    return apiResponse.results!.first as ParseObject;
  } catch (e) {
    throw Exception("Error: getFahrzeugtyp -> $e");
  }
}
