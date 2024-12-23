import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:fahrschul_manager/src/db_classes/status.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<bool> updateFahrschuelerState({required ParseObject fahrschueler, required String state}) async {
  final ParseObject? stateObject = await fetchStatus(state);
  if(stateObject == null)
  {
    return false;
  }
  //Wenn "Nicht zugewiesen" dann setze den Fahrlehrer auf null
  if(state == stateUnassigned)
  {
    fahrschueler.set("Fahrlehrer", null);
  }
  else{
    fahrschueler.set("Fahrlehrer", Benutzer().dbUser!);
  }
  fahrschueler.set('Status', stateObject);
  final response = await fahrschueler.save();
  if(!response.success)
  {
    return false;
  }
  return true;
}

bool hasFahrlehrer(ParseObject fahrschueler)
{
  if(fahrschueler.get<ParseObject?>("Fahrlehrer") != null)
  {
    return true;
  }
  return false;
}

Future<ParseObject> fetchFahrschueler(String id) async {
  final apiResponse = await ParseObject('Fahrschueler').getObject(id);
  return apiResponse.results!.first as ParseObject;
}

Future<List<ParseObject>> fetchAvailableFahrschuelerExcludingIds(List<String> ids) async {
  final stateId = await fetchStatusID(stateActive);
  if(stateId == null) {
    throw ("Failed fetching state id");
  }
    final QueryBuilder<ParseObject> queryBuilder =
      QueryBuilder<ParseObject>(ParseObject('Fahrschueler'))
      ..whereEqualTo("Fahrschule", Benutzer().fahrschule!.objectId!)
      ..whereEqualTo("Fahrlehrer", Benutzer().dbUserId)
      ..whereEqualTo("Status", stateId)
      ..whereNotContainedIn("objectId", ids);

  // Execute the query
  final ParseResponse apiResponse = await queryBuilder.query();

  // Check for success and return the first result
  if (apiResponse.success && apiResponse.results != null) {
    return apiResponse.results as List<ParseObject>;
  }

  // Return null if there were no results or if the query failed
  return [];
}
