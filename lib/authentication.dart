import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Beendet die Session vom user
///
/// ### Parameter:
/// - **`ParseObject` [user]** : der `ParseUser` der ausgeloggt werden soll.
///
/// ### Return value:
/// - **`bool` **
Future<bool> logout(ParseUser user) async {
  try {
    if (user.sessionToken != null) {
      await user.logout();
    }
    return true;
  } catch (e) {
    return false;
  }
}

/// Startet die Session vom user
///
/// ### Parameter:
/// - **`ParseObject` [user]** : der `ParseUser` der eingeloggt werden soll.
///
/// ### Return value:
/// - **`bool` **
Future<bool> login(ParseUser user) async {
  try {
    await user.login();
    return true;
  } catch (e) {
    return false;
  }
}

/// Überprüft ob der User eine gülte Session hat.
/// Ist eine lokale Session gefunden aber nicht übereinstimmend zu dem auf dem Server, wird ein Logout initiiert.
/// Ist die lokale Session übereinstimmend mit dem auf dem Server ist kein login notwendig
///
/// ### Return value:
/// - **`bool` **
Future<bool> hasUserLogged() async {
  ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
  if (currentUser == null) {
    return false;
  }
  //Checks whether the user's session token is valid
  final ParseResponse? parseResponse =
      await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);
  if (parseResponse?.success == null || !parseResponse!.success) {
    //Invalid session. Logout
    await currentUser.logout();
    return false;
  } else {
    return true;
  }
}
