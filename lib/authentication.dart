import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Beendet die Session vom user
///
/// ### Parameter:
/// - **`BuildContext` [context]** : `BuildContext` vom `Widget`.
///
/// ### Return value:
/// - **`bool` **
Future<bool> logout(BuildContext context) async {
  try {
    final user = await getLocalStorageUser();
    if (user == null) {
      return true;
    }
    if (user.sessionToken != null) {
      final response = await user.logout();
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()), //TODO: Anstatt MyApp() sollte LoginPage() sein.
          (Route<dynamic> route) => false,
        );
      } else {
        throw Exception();
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

/// Startet die Session vom user
///
/// ### Parameter:
/// - **`String` [eMail]** : E-Mail vom User.
/// - **`String` [password]** : Passwort vom User.
///
/// ### Return value:
/// - **`bool` **
Future<bool> login(String eMail, String password) async {
  try {
    final user = ParseUser(eMail, password, eMail);
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
