import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// Fügt der angebenen Fahrschule einen Ort in der Datenbank hinzu. Es wird ein Eintrag in der Tabelle `Zuordnung_Ort_Fahrschhule` gemacht.
///
/// ### Parameter:
/// - **`ParseObject` [fahrschuleObject]** : ParseObject von `Fahrschule`
/// - **`ParseObject` [ortObject]** : ParseObject von `Ort`
/// - **`String` [strasse]** : Name der Straße, wo sich die Fahrschule befindet
/// - **`String` [hausnummer]** : Hausnummer der Fahrschule
///
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<void> registerOrtFromFahrschule(
    {required fahrschuleObject,
    required ParseObject ortObject,
    required String strasse,
    required String hausnummer}) async {
  if (strasse.isEmpty || hausnummer.isEmpty) {
    throw const FormatException("empty values are not allowed");
  }

  final obj = ParseObject('Zuordnung_Ort_Fahrschule')
    ..set('Ort', ortObject)
    ..set('Fahrschule', fahrschuleObject)
    ..set('Strasse', strasse)
    ..set('Hausnummer', hausnummer);

  final ParseResponse response = await obj.save();

  if (!response.success) {
    throw Exception("API ERROR");
  }
}

/// Erhalte einen ParseObject von `Zuordnung_Ort_Fahrschule`.
///
/// ### Parameters:
///
/// - **`String` [id]** : objectId von der `Fahrschule`.
///
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
///
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
Future<ParseObject?> getOrtFromFahrschuleWithId(String id) async {
  if (id.isEmpty) {
    throw const FormatException("empty values are not allowed");
  }

  final response = await ParseObject('Zuordnung_Ort_Fahrschule').getObject(id);

  if (!response.success) {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  if (response.results == null || response.results!.isEmpty) {
    return null;
  }
  return response.result as ParseObject;
}

/// Erhalte einen ParseObject von `Fahrschule`.
///
/// ### Parameters:
///
/// - **`String` [id]** : objectId von der `Fahrschule`.
///
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
///
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
Future<ParseObject?> getFahrschuleWithId(String id) async {
  if (id.isEmpty) {
    throw const FormatException("empty values are not allowed");
  }

  final response = await ParseObject('Fahrschule').getObject(id);

  if (!response.success) {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  if (response.results == null || response.results!.isEmpty) {
    return null;
  }
  return response.result as ParseObject;
}

/// Erstelle eine Fahrschule in die Datenbank.
///
/// ### Parameter:
/// - **`String` [name]** : name der Fahrschule
///
/// ### Return value:
/// - **[ParseObject]** : Fahrschule Objekt
///
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<ParseObject> createFahrschule(String name) async {
  if (name.isEmpty) {
    throw const FormatException("Name cannot be empty");
  }
  final fahrschulObject = ParseObject("Fahrschule")..set('Name', name);

  final ParseResponse response = await fahrschulObject.save();
  if (!response.success) {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  logger.i(
      "Fahrschule created successfully. ObjectId: ${response.result.objectId}");
  return response.result as ParseObject;
}

/// Überprüft ob die Fahrschule bereits existiert
///
/// ### Parameter:
/// - **`String` [value] : Name der Fahrschule
///
/// ### Return value:
/// - **[bool]** : `true` wenn Fahrschule bereits existiert. Andernfalls `false`.
///
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<bool> checkIfFahrschuleExists(String value) async {
  if (value.isEmpty) {
    throw const FormatException("empty values are not allowed");
  }

  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Fahrschule'))
        ..whereEqualTo('Name', value);

  final response = await parseQuery.query();

  if (!response.success) {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  if (response.results == null || response.results!.isEmpty) {
    return false;
  }
  return true;
}

Future<List<ParseObject>> fetchAllFahrlehrerFromFahrschule(
    final String id) async {
  try {
    final queryFahrlehrer = QueryBuilder<ParseObject>(ParseObject('Fahrlehrer'))
      ..whereEqualTo('Fahrschule', id);
    final fahrlehrerResponse = await queryFahrlehrer.query();
    if (!fahrlehrerResponse.success || fahrlehrerResponse.results == null) {
      return [];
    }
    return fahrlehrerResponse.results as List<ParseObject>;
  } catch (e) {
    throw ("Failed fetching data");
  }
}
