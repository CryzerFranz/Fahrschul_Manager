import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


/// Sucht nach dem Objekt `Ort` mit dem exakten fields
/// 
/// ### Parameter:
/// - **`String` [name]** : Ortsname
/// - **`String` [plz]** : PLZ des Ortes
/// 
/// ### Return value:
/// - **[String]** : objectId des gefunden Ortes
/// 
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<String> getOrtObjectID(final String name, final String plz) async
{
    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Ort'))
    ..whereContains('PLZ', plz)
    ..whereContains('Name', name)
    ..keysToReturn(['objectId'])
    ..setLimit(1);

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success) 
    {
      throw Exception(apiResponse.error?.message);
    }
    if(apiResponse.results == null || apiResponse.results!.isEmpty)
    {
      throw const FormatException("Not Found");
    }

  return apiResponse.results!.first.get<String>('objectId');
}

/// Erhalte einen ParseObject von `Ort`.
/// 
/// ### Parameters:
/// 
/// - **`String` [name]** : Ortsname von `Ort`.
/// - **`String` [plz]** : PLZ von `Ort`.
/// 
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
/// 
/// ### Exception:
/// - **[FormatException]** : Übergebene Parameter passen nicht zum erwartetem Format.
Future<ParseObject?> getOrt(final String name, final String plz) async
{
    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Ort'))
    ..whereContains('PLZ', plz)
    ..whereContains('Name', name)
    ..setLimit(1);

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success) 
    {
      throw Exception(apiResponse.error?.message);
    }
    if(apiResponse.results == null || apiResponse.results!.isEmpty)
    {
      return null;
    }

  return apiResponse.results!.first as ParseObject;
}