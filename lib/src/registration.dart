import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:fahrschul_manager/doc/intern/Status.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


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
Future<ParseObject> createFahrschueler(String vorname, String name,
    String eMail, final String password, final ParseObject fahrschule,
    {ParseObject? fahrlehrer}) async {
  if (eMail.isEmpty || vorname.isEmpty || name.isEmpty || password.isEmpty) {
    throw const FormatException("Empty values are not allowed");
  }

  try {
    ParseObject? status;
    if (fahrlehrer == null) {
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

    final QueryBuilder<ParseObject> roleQuery =
        QueryBuilder<ParseObject>(ParseObject('_Role'))
          ..whereEqualTo(
              'name', 'Fahrschueler'); // Suche nach der Rolle 'fahrlehrer'

    final roleResponse = await roleQuery.query();

    if (roleResponse.success &&
        roleResponse.results != null &&
        roleResponse.results!.isNotEmpty) {
      final fahrlehrerRole = roleResponse.results!.first as ParseObject;
      final roleUserRelation = fahrlehrerRole.getRelation("users");
      roleUserRelation.add(parseUser);

      // Benutzer zur Rolle hinzufügen
      final saveRoleResponse = await fahrlehrerRole.save();

      if (!saveRoleResponse.success) {
        throw Exception(
            "Failed to assign role 'Fahrschueler' to user: ${saveRoleResponse.error!.message}");
      }
    }

    await parseUser.logout();

    return response.result as ParseObject;
  } catch (e) {
    throw Exception("Error: createFahrschueler -> $e");
  }
}

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

    final QueryBuilder<ParseObject> roleQuery = QueryBuilder<ParseObject>(
        ParseObject('_Role'))
      ..whereEqualTo('name', 'Fahrlehrer'); // Suche nach der Rolle 'fahrlehrer'

    final roleResponse = await roleQuery.query();

    if (roleResponse.success &&
        roleResponse.results != null &&
        roleResponse.results!.isNotEmpty) {
      final fahrlehrerRole = roleResponse.results!.first as ParseObject;
      final roleUserRelation = fahrlehrerRole.getRelation("users");
      roleUserRelation.add(parseUser);

      // Benutzer zur Rolle hinzufügen
      final saveRoleResponse = await fahrlehrerRole.save();

      if (!saveRoleResponse.success) {
        throw Exception(
            "Failed to assign role 'fahrlehrer' to user: ${saveRoleResponse.error!.message}");
      }
    }
    final isCreated = await Benutzer().login(eMail, password);
    if (!createSession || !isCreated) {
      await Benutzer().logout();
    }

    return response.result as ParseObject;
  } catch (e) {
    throw Exception("Error: createFahrlehrer -> $e");
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

/// Erstellt eine Fahrschule und speichert die zugehörigen Informationen.
///
/// Dabei wird ein Eintrag in `Zuordnung_Ort_Fahrschule` erstellt.
/// Der Ort wird von der Datenbank abgefragt.
/// Zusätzlich wird ein Fahrlehrer erstellt, der die Fahrschule erstellt hat bzw. zu dieser gehört.
///
/// ### Parameters:
/// - **`String` [fahrschulName]**: Name für die Fahrschule.
/// - **`ParseObject` [ortObject]**: objectId vom Ort.
/// - **`String` [strasse]**: Für die dazugehörige Straße.
/// - **`String` [hausnummer]**: Für die dazugehörige Hausnummer.
/// - **`String` [eMail]**: E-Mail adresse des Benutzers.
/// - **`String` [password]**: Passwort des Benutzers.
/// - **`String` [vorname]**: Vorname des Benutzers.
/// - **`String` [name]**: Name des Benutzers.
/// 
/// ### Exceptions:
/// - **[Exception]**
Future<void> fahrschuleRegistration(
  String fahrschulName,
  ParseObject ortObject,
  String strasse,
  String hausnummer,
  String eMail,
  String password,
  String vorname,
  String name) async {
  try{
    //Fahrschule erstellen
    final fahrschulObject = await createFahrschule(fahrschulName);
   
    //Eintrag in Zuordnung_Ort_Fahrschule erstellen
    await registerOrtFromFahrschule(fahrschuleObject: fahrschulObject,ortObject: ortObject,strasse: strasse,hausnummer: hausnummer);
    await createFahrlehrer(vorname, name, eMail, fahrschulObject, password, createSession: true);
  } catch (e)
  {
    throw e.toString();
  }
}