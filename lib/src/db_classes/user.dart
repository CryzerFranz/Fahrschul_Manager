// user.dart beinhaltet funktionen für folgende Datenbankklassen:
// _User
// Fahrlehrer
// Fahrschueler

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
Future<ParseUser?> getParseUserFromId(String objectId) async
{
  if(objectId.isEmpty)
  {
    throw const FormatException("Empty values are not allowed");
  }
  final query = QueryBuilder<ParseUser>(ParseUser.forQuery())
    ..whereEqualTo('objectId', objectId);

     final response = await query.query();

     if(response.success)
     {
        return response.results!.first as ParseUser;
     }
     return null;
}

/// Erstellt einen ParseUser (_User).
/// 
/// ### Parameters:
/// 
/// - **`String` [eMail]** : E-Mail adresse vom Benutzer, sowie auch der Username.
/// - **`String` [password]** : Passwort des Benutzers.
/// 
/// ### Return value:
/// - **[String]** : Gibt die objectId vom ParseUser zurück.
/// 
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
/// - **[Exception]** : Etwas ist beim registrieren schief gelaufen.
Future<String> createUser(final String eMail, final String password, {bool returnId = true}) async {
  if(eMail.isEmpty || password.isEmpty)
  {
    throw const FormatException("Empty values are not allowed");
  }

  // user eMail as username
  final user = ParseUser.createUser(eMail, password, eMail);
  var response = await user.signUp();
  
  if (!response.success) 
  {
    throw Exception(response.error?.message);
  }
  return response.results?.first.get<String>('objectId');
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
/// 
/// ### Return value:
/// - **[String]** : Gibt die objectId vom Fahrlehrer objekt zurück.
/// 
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
/// - **[Exception]** : Etwas ist beim registrieren schief gelaufen.
Future<String> createFahrlehrer(String vorname, String name, String eMail, final ParseObject fahrschulObject, final String password) async {
  if(eMail.isEmpty  || vorname.isEmpty || name.isEmpty )
  {
    throw const FormatException("Empty values are not allowed");
  }

  try{
    final userId = await createUser(eMail, password);
    final parseUser = await getParseUserFromId(userId);
    
    if(parseUser == null)
    {
      throw const FormatException("ParseUser null exception");
    }

    final fahrlehrerObj = ParseObject('Fahrlehrer')
    ..set('Name', name)
    ..set('Fahrschule', fahrschulObject)
    ..set('Vorname', vorname)
    ..set('Email', eMail)
    ..set('UserObject', parseUser);

    final ParseResponse response = await fahrlehrerObj.save();

    if (!response.success) 
    {
      throw Exception(response.error?.message);
    }
    return response.result.objectId;
  } catch (e)
  {
    throw Exception(e.toString());
  }
}
