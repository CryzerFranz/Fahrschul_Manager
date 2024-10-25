import 'package:fahrschul_manager/src/db_classes/ort.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
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
/// ### Return value:
/// - ** [String]** : objectId
/// 
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<String> registerOrtFromFahrschule(ParseObject fahrschuleObject, ParseObject ortObject, String strasse, String hausnummer) async{
  if(strasse.isEmpty || hausnummer.isEmpty)
  {
    throw const FormatException("empty values are not allowed");
  }

  final obj = ParseObject('Zuordnung_Ort_Fahrschule')
  ..set('Ort', ortObject)
  ..set('Fahrschule', fahrschuleObject)
  ..set('Strasse', strasse)
  ..set('Hausnummer', hausnummer);

  final ParseResponse response = await obj.save();

  if(!response.success)
  {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  logger.i("Zuordnung_Ort_Fahrschule created successfully. ObjectId: ${response.result.objectId}");
  return response.result.objectId;
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
Future<ParseObject?> getOrtFromFahrschuleWithId(String id) async{
  if(id.isEmpty)
  {
    throw const FormatException("empty values are not allowed");
  }

  final response = await ParseObject('Zuordnung_Ort_Fahrschule').getObject(id);

  if(!response.success)
  {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  if(response.results == null || response.results!.isEmpty)
  {
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
Future<ParseObject?> getFahrschuleWithId(String id) async{
  if(id.isEmpty)
  {
    throw const FormatException("empty values are not allowed");
  }

  final response = await ParseObject('Fahrschule').getObject(id);

  if(!response.success)
  {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  if(response.results == null || response.results!.isEmpty)
  {
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
/// - **[String]** : objectId der Fahrschule
/// 
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<String> createFahrschule(String name) async {
  if(name.isEmpty)
  {
    throw const FormatException("Name cannot be empty");
  }
  final fahrschulObject = ParseObject("Fahrschule")
    ..set('Name', name);

  final ParseResponse response = await fahrschulObject.save();
  if(!response.success)
  {
    logger.e(response.error?.message);
    throw Exception(response.error?.message);
  }
  logger.i("Fahrschule created successfully. ObjectId: ${response.result.objectId}");
  return response.result.objectId;
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
    final fahrschulObjectId = await createFahrschule(fahrschulName);
    //Fahrschule ParseObject 
    final fahrschulObject = await getFahrschuleWithId(fahrschulObjectId);
    if(fahrschulObject == null)
    {
      throw const FormatException("Fahrschule null exception");
    }
    //Eintrag in Zuordnung_Ort_Fahrschule erstellen
    await registerOrtFromFahrschule(fahrschulObject, ortObject, strasse, hausnummer);
    await createFahrlehrer(vorname, name, eMail, fahrschulObject, password);
  } catch (e)
  {
    throw e.toString();
  }
}
