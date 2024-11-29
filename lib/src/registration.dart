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
      status = await fetchStatus("Nicht zugewiesen");
    }
    status = await fetchStatus("Passiv");

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
      final fahrschuelerRole = roleResponse.results!.first as ParseObject;
      final roleUserRelation = fahrschuelerRole.getRelation("users");
      roleUserRelation.add(parseUser);

      // Benutzer zur Rolle hinzufügen
      final saveRoleResponse = await fahrschuelerRole.save();

      if (!saveRoleResponse.success) {
        throw Exception(
            "Failed to assign role 'Fahrschueler' to user: ${saveRoleResponse.error!.message}");
      }
    }

    //await parseUser.logout();

    return response.result as ParseObject;
  } catch (e) {
    throw Exception("Error: createFahrschueler -> $e");
  }
}

/// Erstellt einen neuen Eintrag in `Fahrlehrer`.
///
/// ### Parameters:
///
/// - **`required` `String` [vorname]** : Vorname des Fahrlehrers.
/// - **`required` `String` [name]** : Name des Fahrlehrers.
/// - **`required` `String` [eMail]** : E-Mail adresse vom Fahrlehrer.
/// - **`required` `String` [ParseObject]** : Das ParseObject Fahrschule zudem der Fahrlehrer gehört.
/// - **`required` `String` [password]** : Passwort des Benutzers.
/// - **`optional` `bool` [createSession]** : **OPTIONAL** Default: `false`. Erstellt eine Session bei `true`
///
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
/// - **[Exception]** : Etwas ist beim registrieren schief gelaufen.
Future<void> createFahrlehrer(
    {required vorname,
    required String name,
    required String eMail,
    required final ParseObject fahrschulObject,
    required final String password,
    bool createSession = false}) async {
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
    if(createSession)
    {
      await Benutzer().login(eMail, password);

    }
    // if (!createSession || !isCreated) {
    //   await Benutzer().logout();
    // }
  } catch (e) {
    throw Exception("Error: createFahrlehrer -> $e");
  }
}

/// Erstellt einen ParseUser in der Datenbank
Future<ParseUser> createUser(String eMail, String password) async {
  try {
    if (eMail.isEmpty || password.isEmpty) {
      throw const FormatException("Empty values are not allowed");
    }

    // Call the cloud function for user creation
    final ParseCloudFunction createUserFunction = ParseCloudFunction('createUser');
    final Map<String, dynamic> params = <String, dynamic>{
      'email': eMail,
      'password': password,
    };

    final ParseResponse response = await createUserFunction.execute(parameters: params);

    if (!response.success || response.result == null) {
      throw Exception(response.error?.message);
    }

    // Cloud function returns the created user
    return ParseUser(null, null, null)..fromJson(response.result);
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
/// - **`required` `String` [fahrschulName]**: Name für die Fahrschule.
/// - **`required` `ParseObject` [ortObject]**: objectId vom Ort.
/// - **`required` `String` [strasse]**: Für die dazugehörige Straße.
/// - **`required` `String` [hausnummer]**: Für die dazugehörige Hausnummer.
/// - **`required` `String` [eMail]**: E-Mail adresse des Benutzers.
/// - **`required` `String` [password]**: Passwort des Benutzers.
/// - **`required` `String` [vorname]**: Vorname des Benutzers.
/// - **`required` `String` [name]**: Name des Benutzers.
///
/// ### Exceptions:
/// - **[Exception]**
Future<void> fahrschuleRegistration(
    {required String fahrschulName,
    required ParseObject ortObject,
    required String strasse,
    required String hausnummer,
    required String eMail,
    required String password,
    required String vorname,
    required String name}) async {
  try {
    //Fahrschule erstellen
    final fahrschulObject = await createFahrschule(fahrschulName);

    //Eintrag in Zuordnung_Ort_Fahrschule erstellen
    await registerOrtFromFahrschule(
        fahrschuleObject: fahrschulObject,
        ortObject: ortObject,
        strasse: strasse,
        hausnummer: hausnummer);
    await createFahrlehrer(
        vorname: vorname,
        name: name,
        eMail: eMail,
        fahrschulObject: fahrschulObject,
        password: password,
        createSession: true);
  } catch (e) {
    throw e.toString();
  }
}

/// Überprüft ob die E-Mail Addresse bereits vergeben ist
/// 
/// Die eigentlich logik der Funktion ist in Cloud Code von Back4App, da der 
/// `MasterKey` sicher verwendet werden kann
Future<bool> doesUserExist(String email) async {
  try{
  final ParseCloudFunction function = ParseCloudFunction('doesUserExist');
  final ParseResponse response = await function.execute(parameters: {'email': email});
  if(!response.success){
    throw("Network error");
  }
  if (response.success && response.result == true) {
    return true; 
  } else {
    return false; 
  }
  }catch(e){throw(e.toString());}
}
