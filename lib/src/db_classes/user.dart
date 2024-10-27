// user.dart beinhaltet funktionen für folgende Datenbankklassen:
// _User
// Fahrlehrer
// Fahrschueler

import 'package:fahrschul_manager/authentication.dart';
import 'package:fahrschul_manager/src/db_classes/status.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// _User sektion

/// Erhalte einen ParseUser (_User).
///
/// ### Parameters:
///
/// - **`String` [objectId]** : objectId vom `ParseUser`.
///
/// ### Return value:
/// - **[ParseUser?]** : `ParseUser` || `null`
///
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
Future<ParseUser?> getParseUserFromId(String objectId) async {
  try {
    if (objectId.isEmpty) {
      throw const FormatException("Empty values are not allowed");
    }
    final query = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereEqualTo('objectId', objectId);

    final response = await query.query();

    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseUser;
    }
    return null;
  } catch (e) {
    throw Exception("Error: getParseUserFromId -> $e");
  }
}

/// Erstellt einen ParseUser (_User).
///
/// ### Parameters:
///
/// - **`String` [eMail]** : E-Mail adresse vom Benutzer, sowie auch der Username.
/// - **`String` [password]** : Passwort des Benutzers.
///
/// ### Return value:
/// - **[ParseUser]** : Gibt den ParseUser zurück.
///
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
/// - **[Exception]** : Etwas ist beim registrieren schief gelaufen.
Future<ParseUser> createUser(final String eMail, final String password) async {
  try {
    if (eMail.isEmpty || password.isEmpty) {
      throw const FormatException("Empty values are not allowed");
    }

    // user eMail as username
    final user = ParseUser.createUser(eMail, password, eMail);
    var response = await user.signUp();

    if (!response.success) {
      throw Exception(response.error!.message);
    }
    return response.results?.first as ParseUser;
  } catch (e) {
    throw Exception("Error: createUser -> $e");
  }
}

// Fahrlehrer sektion

/// Erstellt einen neuen Eintrag in `Fahrlehrer`.
///
/// ### Parameters:
///
/// - **`String` [vorname]** : Vorname des Fahrlehrers.
/// - **`String` [name]** : Name des Fahrlehrers.
/// - **`String` [eMail]** : E-Mail adresse vom Fahrlehrer.
/// - **`String` [ParseObject]** : Das ParseObject Fahrschule zudem der Fahrlehrer gehört.
/// - **`String` [password]** : Passwort des Benutzers.
/// - **`bool` [createSession]** : **OPTIONAL** Default: `false`. Erstellt eine Session bei `true`
///
/// ### Return value:
/// - **[ParseObject]** : Gibt Fahrlehrer als Objekt zurück.
///
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
/// - **[Exception]** : Etwas ist beim registrieren schief gelaufen.
Future<ParseObject> createFahrlehrer(String vorname, String name, String eMail,
    final ParseObject fahrschulObject, final String password,
    {bool createSession = false}) async {
  if (eMail.isEmpty || vorname.isEmpty || name.isEmpty) {
    throw const FormatException("Empty values are not allowed");
  }

  try {
    final parseUser = await createUser(eMail, password);

    final fahrlehrerObj = ParseObject('Fahrlehrer')
      ..set('Name', name)
      ..set('Fahrschule', fahrschulObject)
      ..set('Vorname', vorname)
      ..set('Email', eMail)
      ..set('UserObject', parseUser);

    final ParseResponse response = await fahrlehrerObj.save();

    if (!response.success) {
      throw Exception(response.error?.message);
    }
    if(!createSession)
    {
      await logout(parseUser);
    }
  
    return response.result as ParseObject;
  } catch (e) {
    throw Exception("Error: createFahrlehrer -> $e");
  }
}

// Fahrschüler sektion
//TODO implementation
/// Erstellt einen neuen Eintrag in `Fahrschueler`.
///
/// ### Parameters:
///
/// - **`String` [vorname]** : Vorname des Fahrschülers.
/// - **`String` [name]** : Name des Fahrschülers.
/// - **`String` [eMail]** : E-Mail adresse vom Fahrschüler.
/// - **`String` [password]** : Passwort des Benutzers.
/// - **`ParseObject` [fahrschule]** : Fahrschule zudem der Fahrschüler gehört.
/// - **`ParseObject?` [fahrlehrer]** : **OPTIONAL** weisst dem Fahrschüler einen Fahrlehrer zu.
/// 
///
/// ### Return value:
/// - **[ParseObject]** : Gibt Fahrschueler als Objekt zurück.
///
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
/// - **[Exception]** : Etwas ist beim registrieren schief gelaufen.
Future<ParseObject> createFahrschueler(String vorname, String name, String eMail, final String password, final ParseObject fahrschule, {ParseObject? fahrlehrer}) async {
  if (eMail.isEmpty || vorname.isEmpty || name.isEmpty || password.isEmpty) {
    throw const FormatException("Empty values are not allowed");
  }

  try {
    ParseObject? status;
    if(fahrlehrer == null)
    {
      status = await getStatus("Nicht zugewiesen");
    }
    status = await getStatus("Passiv");

    final parseUser = await createUser(eMail, password);

    final fahrschuelerObj = ParseObject('Fahrschueler')
      ..set('Name', name)
      ..set('Vorname', vorname)
      ..set('Email', eMail)
      ..set('UserObject', parseUser)
      ..set('Gesamtfahrstunden', 0)
      ..set('Status', status!)
      ..set('Fahrschule', fahrschule)
      ..set('Fahrlehrer', fahrlehrer);

    final ParseResponse response = await fahrschuelerObj.save();

    if (!response.success) {
      throw Exception(response.error?.message);
    }

    await logout(parseUser);
    return response.result as ParseObject;
  } catch (e) {
    throw Exception("Error: createFahrschueler -> $e");
  }
}
