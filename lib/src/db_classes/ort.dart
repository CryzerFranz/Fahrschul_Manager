import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Erhalte einen ParseObject von `Ort`.
/// 
/// ### Parameters:
/// 
/// - **`String` [plz]** : PLZ von `Ort`.
/// 
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
/// 
/// ### Exception:
/// - **[Exception]**
Future<ParseObject?> fetchOrt(final String plz) async
{
    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Ort'))
    ..whereContains('PLZ', plz)
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

/// Gibt eine Liste von "Ort"-Objekten zurück, bei denen das Feld "PLZ" mit der angegebenen Postleitzahl (PLZ) beginnt.
/// 
/// ### Return value:
/// - **[List<ParseObject>]**
/// 
/// /// ### Exception:
/// - **[Exception]** 
Future<List<ParseObject>> fetchOrtObjects(final String plz) async
{
    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Ort'))
    ..whereStartsWith('PLZ', plz);

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success) 
    {
      throw Exception(apiResponse.error?.message);
    }
    if(apiResponse.results == null || apiResponse.results!.isEmpty)
    {
      return [];
    }

  return apiResponse.results as List<ParseObject>;
}