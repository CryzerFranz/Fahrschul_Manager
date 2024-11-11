import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

//TODO TEST
/// Fügt ein Fahrzeug zur Fahrschule hinzu
Future<bool> addFahrzeug(
    ParseObject getriebe, ParseObject fahrzeugtyp, ParseObject marke,
    {String? label, bool anhaengerkupplung = false}) async {
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

//TODO NUR ZUM TESTEN DA WAHRSCHEINLICH
Future<ParseObject> getFahrzeuge(String id) async {
    final apiResponse = await ParseObject('Fahrzeug').getObject(id);
    return apiResponse.results!.first as ParseObject;
}

//TODO TEST
Future<List<ParseObject>> getAllFahrzeuge(ParseObject fahrschule) async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Fahrzeug'))
        ..whereContains("Fahrschule", fahrschule.objectId!);

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success || apiResponse.results == null) {
      return [];
    }

    return apiResponse.results as List<ParseObject>;
}

Future<List<ParseObject>> getAllGetriebe() async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Getriebe'));

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success || apiResponse.results == null) {
      return [];
    }

    return apiResponse.results as List<ParseObject>;
}

Future<List<ParseObject>> getAllMarke() async {
    final QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('Marke'));

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success || apiResponse.results == null) {
      return [];
    }

    return apiResponse.results as List<ParseObject>;
}

Future<List<ParseObject>> getAllFahrzeugtyp() async {
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
