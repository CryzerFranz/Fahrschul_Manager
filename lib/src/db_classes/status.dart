import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Sucht nach dem Objekt `Status` mit dem exakten fields
/// 
/// ### Parameter:
/// - **`String` [status]** : Typ des Status
/// 
/// ### Werte
/// - Nicht zugewiesen
/// - Passiv
/// - Aktiv
/// - Abgeschlossen
/// 
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` von `Status`
/// 
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<ParseObject?> fetchStatus(String status) async {
  try {
    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('Status'))
          ..whereContains('Typ', status);

    final apiResponse = await query.query();

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message);
    }
    if (apiResponse.results == null || apiResponse.results!.isEmpty) {
      return null;
    }
    return apiResponse.results?.first as ParseObject;
  } catch (e) {
    throw Exception("Error: getStatus -> $e");
  }
}

/// Sucht nach dem Objekt `Status` mit dem exakten fields
/// 
/// ### Parameter:
/// - **`String` [status]** : Typ des Status
/// 
/// ### Werte
/// - Nicht zugewiesen
/// - Passiv
/// - Aktiv
/// - Abgeschlossen
/// 
/// ### Return value:
/// - **[String?]** : `ObjectId` von `Status`
/// 
/// ### Exceptions:
/// - **[FormatException]**
/// - **[Exception]**
Future<String?> fetchStatusID(String status) async {
  try {
    final QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('Status'))
          ..whereContains('Typ', status)
          ..keysToReturn(["ObjectId"]);

    final apiResponse = await query.query();

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message);
    }
    if (apiResponse.results == null || apiResponse.results!.isEmpty) {
      return null;
    }
    return apiResponse.results?.first.get<String>("objectId") as String;
  } catch (e) {
    throw Exception("Error: getStatus -> $e");
  }
}
