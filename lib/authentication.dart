import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<bool> logout(ParseUser user) async {
  try{
    if(user.sessionToken != null)
    {
      await user.logout();
    }
    return true;
  } catch(e)
  {
    return false;
  }

}