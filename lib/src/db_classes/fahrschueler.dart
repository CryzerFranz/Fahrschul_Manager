import 'package:fahrschul_manager/src/db_classes/status.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<bool> updateFahrschuelerState({required ParseObject fahrschueler, required String state}) async {
  final ParseObject? stateObject = await fetchStatus(state);
  if(stateObject == null)
  {
    return false;
  }
  fahrschueler.set('Status', stateObject);
  final response = await fahrschueler.save();
  if(!response.success)
  {
    return false;
  }
  return true;
}