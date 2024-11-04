import 'package:fahrschul_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// TEST singleton klasse

/// Die `Benutzer`-Klasse verwaltet die Benutzerauthentifizierung und die Benutzerrolle
/// innerhalb der Anwendung. Sie implementiert ein Singleton-Muster, um sicherzustellen,
/// dass nur eine Instanz der Klasse während der gesamten Lebensdauer der Anwendung
/// existiert.
///
/// ### Eigenschaften:
/// - **Private Variablen**:
///   - `_isLogged` : Gibt an, ob der Benutzer angemeldet ist.
///   - `_isFahrlehrer` : Speichert, ob der Benutzer ein Fahrlehrer ist.
///   - `_fahrschule` : Referenz auf die Fahrschule des Benutzers.
///   - `_dbUser` : Speichert das Benutzerobjekt aus der Datenbank.
///   - `_parseUser` : Speichert das aktuelle `ParseUser`-Objekt.
///
/// - **Öffentliche Getter**:
///   - `isFahrlehrer` : Gibt an, ob der Benutzer ein Fahrlehrer ist.
///   - `fahrschule` : Gibt die Fahrschule des Benutzers zurück.
///   - `parseUser` : Gibt das aktuelle `ParseUser`-Objekt zurück.
///   - `dbUser` : Gibt das Benutzerobjekt aus der Datenbank zurück.
///   - `dbUserId` : Gibt die ID des Benutzerobjekts zurück.
///
/// ### Methoden:
/// - `initialize(ParseUser user)` : Initialisiert den Zustand des Benutzers und
///   überprüft dessen Authentifizierung.
///
/// - `_setUser()` : Setzt das Benutzerobjekt basierend auf der Rolle des aktuellen Benutzers.
///
/// - `clear()` : Setzt alle Benutzerdaten und Sitzungsinformationen zurück.
///
/// - `_clearNavigator()` : Leert den Navigator-Stack und navigiert zur Startseite.
///
/// - `logout()` : Loggt den aktuellen Benutzer aus und bereinigt die lokale Benutzersitzung.
///
/// - `login()` : Loggt den Benutzer mit den aktuellen Anmeldeinformationen ein.
///
/// - `updateAll()` : Aktualisiert den aktuellen Benutzerstatus und überprüft die Benutzerrolle.
///
/// - `_checkIsUserFahrlehrer()` : Überprüft, ob der aktuelle Benutzer die Rolle "Fahrlehrer" besitzt.
///
/// - `_updateParseUser()` : Aktualisiert den aktuellen `ParseUser`-Status vom Server.
///
/// - `getUserRoles()` : Ruft die Rollen des aktuell eingeloggten Benutzers ab.
///
/// - `hasUserLogged()` : Überprüft, ob der Benutzer aktuell eingeloggt ist.
///
/// ### Ausnahmebehandlung:
/// Einige Methoden in dieser Klasse können Ausnahmen werfen oder fangen,
/// insbesondere beim Abrufen von Benutzerdaten oder beim Login/Logout-Prozess.
class Benutzer {
  //TODO

  // Private constructor for singleton
  Benutzer._internal();

  // Singleton instance
  static final Benutzer _instance = Benutzer._internal();

  // Factory constructor to provide the same instance
  factory Benutzer() => _instance;

  // Private variables
  bool _isLogged = false;
  bool? _isFahrlehrer = false;
  ParseObject? _fahrschule;
  ParseObject? _dbUser;
  ParseUser? _parseUser;

  // Public getters for accessing private variables
  bool? get isFahrlehrer => _isFahrlehrer;
  ParseObject? get fahrschule => _fahrschule;
  ParseUser? get parseUser => _parseUser;
  ParseObject? get dbUser => _dbUser;

  // Public getters
  String? get dbUserId => _dbUser?.objectId;

  /// Initialisiert den Zustand des Benutzers und überprüft dessen Authentifizierung.
  ///
  /// Diese Methode setzt den aktuellen Benutzer und überprüft, ob der Benutzer
  /// angemeldet ist. Wenn der Benutzer erfolgreich eingeloggt ist, wird dessen Rolle
  /// ermittelt und die zugehörigen Benutzerdaten werden gesetzt. Bei einem
  /// ungültigen Benutzer wird eine Ausnahme ausgelöst.
  ///
  /// ### Parameter:
  /// - **`ParseUser user`** : Der Benutzer, der zur Initialisierung verwendet wird.
  ///
  /// ### Rückgabewert:
  /// - **[Future<bool>]** : Gibt `true` zurück, wenn der Benutzer erfolgreich
  ///   initialisiert wurde, andernfalls `false`.
  ///
  /// ### Ausnahme:
  /// - **[Exception]** : Wird geworfen, wenn der Benutzer ungültig ist,
  ///   d.h. `_dbUser` ist `null`.
  Future<bool> initialize({required ParseUser? user}) async {
    _parseUser = user;
    if (await hasUserLogged()) {
      _isLogged = true;
      _isFahrlehrer = await _checkIsUserFahrlehrer();
      await _setUser();
      if (_dbUser == null) {
        return false;
      }
      _fahrschule = _dbUser!.get<ParseObject>('Fahrschule');
      return true;
    }
    _isLogged = false;
    _fahrschule = null;
    _isFahrlehrer = null;
    return false;
  }

  //TODO TEST
  /// Setzt das Benutzerobjekt basierend auf der Rolle des aktuellen Benutzers.
  ///
  /// Diese Methode ermittelt das `ParseObject` des Benutzers entweder aus der
  /// `Fahrlehrer`- oder `Fahrschueler`-Klasse, basierend auf der Benutzerrolle,
  /// und speichert es in `_dbUser`. Falls keine gültigen Benutzerdaten gefunden
  /// werden, werden die Benutzerdaten zurückgesetzt.
  ///
  /// ### Rückgabewert:
  /// - **[Future<void>]** : Diese Methode gibt keinen Wert zurück.
  ///
  /// ### Seiteneffekte:
  /// - Setzt `_dbUser` auf das ermittelte `ParseObject` oder ruft `clear()` auf,
  ///   falls keine Ergebnisse gefunden werden.
  ///
  /// ### Ausnahme:
  /// - Diese Methode wirft keine expliziten Ausnahmen.
  Future<void> _setUser() async {
    if (_isFahrlehrer != null && _parseUser != null) {
      final QueryBuilder<ParseObject> parseQuery;
      if (_isFahrlehrer!) {
        parseQuery = QueryBuilder<ParseObject>(ParseObject('Fahrlehrer'))
          ..whereContains('UserObject', _parseUser!.objectId!);
      } else {
        parseQuery = QueryBuilder<ParseObject>(ParseObject('Fahrschueler'))
          ..whereContains('UserObject', _parseUser!.objectId!);
      }
      parseQuery.includeObject(['Fahrschule']);
      final apiResponse = await parseQuery.query();
      if (apiResponse.success &&
          apiResponse.results != null &&
          apiResponse.results!.isNotEmpty) {
        _dbUser = apiResponse.results!.first as ParseObject;
        return;
      }
    }
    await clear();
  }

  /// Setzt alle Benutzerdaten und Sitzungsinformationen zurück.
  ///
  /// Diese Methode löscht die aktuellen Benutzerdaten und setzt die relevanten
  /// Variablen auf ihren Anfangszustand, um die Sitzung zu beenden.
  ///
  /// ### Rückgabewert:
  /// - **[Future<void>]** : Diese Methode gibt keinen Wert zurück.
  Future<void> clear() async {
    _isFahrlehrer = null;
    _fahrschule = null;
    _parseUser = null;
    _isLogged = false;
  }

  /// Leert den Navigator-Stack und navigiert zur Startseite.
  ///
  /// Diese Methode entfernt alle bisherigen Seiten aus dem Navigator-Stack und
  /// leitet den Benutzer zur definierten Startseite weiter.
  ///
  /// ### Rückgabewert:
  /// - **[void]** : Diese Methode gibt keinen Wert zurück.
  ///
  /// ### Hinweis:
  /// - Aktuell navigiert die Methode zur `MyApp()`-Seite. Zukünftig sollte hier
  ///   die `LoginPage()` verwendet werden (siehe TODO).
  void _clearNavigator() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              MyApp()), //TODO: Anstatt MyApp() sollte LoginPage() sein.
      (Route<dynamic> route) => false,
    );
  }

  /// Loggt den aktuellen Benutzer aus und bereinigt die lokale Benutzersitzung.
  ///
  /// Diese Methode beendet die aktuelle Benutzersitzung und entfernt alle
  /// lokalen Benutzerdaten, falls ein Benutzer eingeloggt ist.
  ///
  /// ### Rückgabewert:
  /// - **[Future<bool>]** : Diese Methode gibt true oder false zurück.
  ///
  /// ### Ausnahme:
  /// - Diese Methode fängt Ausnahmen ab und wirft keine expliziten Fehler, falls der Logout fehlschlägt.
  Future<bool> logout() async {
    if (_parseUser != null) {
      if (_parseUser!.sessionToken != null) {
        final response = await _parseUser!.logout();
        if (!response.success) {
          return false;
        }
        await clear();
      }
    }
    _clearNavigator();
    return true;
  }

  /// Loggt den Benutzer mit den aktuellen Anmeldeinformationen ein.
  ///
  /// Diese Methode führt den Login-Prozess für den aktuellen Benutzer durch und gibt
  /// das Ergebnis des Login-Versuchs zurück.
  ///
  /// ### Rückgabewert:
  /// - **[Future<bool>]** : Gibt `true` zurück, wenn der Login erfolgreich war,
  ///   andernfalls `false`.
  ///
  /// ### Ausnahme:
  /// - Diese Methode fängt Ausnahmen ab und gibt `false` zurück, falls der Login fehlschlägt.
  Future<bool> login() async {
    final response = await _parseUser!.login();
    if(response.success){
      _isLogged = true;
      _isFahrlehrer = await _checkIsUserFahrlehrer();
      await _setUser();
      if (_dbUser == null) {
        return false;
      }
      _fahrschule = _dbUser!.get<ParseObject>('Fahrschule');
      return true;
    }
    return false;
  }

//TODO
  Future<void> updateAll() async {
    await _updateParseUser();
    await _checkIsUserFahrlehrer();
  }

  /// Überprüft, ob der aktuelle Benutzer die Rolle "Fahrlehrer" besitzt.
  ///
  /// Diese Methode durchsucht die Rollen des aktuellen Benutzers und gibt `true` zurück,
  /// wenn eine der Rollen den Namen "Fahrlehrer" trägt.
  ///
  /// ### Rückgabewert:
  /// - **[Future<bool>]** : Gibt `true` zurück, falls der Benutzer die Rolle "Fahrlehrer" hat,
  ///   andernfalls `false`.
  ///
  /// ### Ausnahme:
  /// - Diese Methode wirft keine expliziten Ausnahmen.
  Future<bool> _checkIsUserFahrlehrer() async {
    List<ParseObject> roleList = await getUserRoles();
    for (var roles in roleList) {
      if (roles.get<String>('name') == "Fahrlehrer") {
        return true;
      }
    }
    return false;
  }

  /// Aktualisiert den aktuellen `ParseUser`-Status vom Server.
  ///
  /// Diese Methode synchronisiert den aktuellen Benutzerstatus, indem sie eine Anfrage an den Server
  /// sendet, um sicherzustellen, dass der Benutzer noch gültig eingeloggt ist. Falls der Benutzer
  /// nicht mehr gültig ist, wird die Methode `logout()` aufgerufen, um den Benutzer auszuloggen.
  ///
  /// ### Rückgabewert:
  /// - **[Future<void>]** : Diese Methode gibt keinen Wert zurück.
  ///
  /// ### Ausnahme:
  /// - Diese Methode wirft keine expliziten Ausnahmen, nutzt jedoch `logout()`, falls der Server
  ///   den Benutzer als nicht mehr gültig betrachtet.
  Future<bool> _updateParseUser() async {
    final ParseResponse? parseResponse =
        await ParseUser.getCurrentUserFromServer(_parseUser!.sessionToken!);
    if (parseResponse?.success != null &&
        parseResponse!.success &&
        parseResponse.results != null) {
      _parseUser = parseResponse.results!.first as ParseUser;
      return true;
    } else {
      return false;
    }
  }

  /// Ruft die Rollen des aktuell eingeloggten Benutzers ab.
  ///
  /// Diese Methode führt eine Abfrage auf der `_Role`-Klasse durch, um eine Liste der Rollen
  /// zu erhalten, die dem aktuellen Benutzer zugeordnet sind.
  ///
  /// ### Rückgabewert:
  /// - **[Future<List<ParseObject>>]** : Gibt eine Liste von `ParseObject`-Instanzen zurück,
  ///   die die Rollen des Benutzers repräsentieren. Wenn der Benutzer keine Rollen besitzt
  ///   oder nicht eingeloggt ist, wird eine leere Liste zurückgegeben.
  ///
  /// ### Ausnahme:
  /// - **[Exception]** : Wird geworfen, falls die Abfrage fehlschlägt, mit der Meldung
  ///   `"Error: getUserRoles -> Query failed"`.
  Future<List<ParseObject>> getUserRoles() async {
    if (!_isLogged) {
      _clearNavigator();
    } else {
      // Create a query on the _Role class
      final QueryBuilder<ParseObject> roleQuery =
          QueryBuilder<ParseObject>(ParseObject('_Role'))
            ..whereContainedIn('users', [_parseUser]);

      // Execute the query
      final ParseResponse response = await roleQuery.query();

      if (response.success && response.results != null) {
        // If successful, response.results will contain the list of roles
        return response.results as List<ParseObject>;
      }
    }
    return [];
  }

  /// Überprüft, ob der Benutzer aktuell eingeloggt ist.
  ///
  /// Diese Methode überprüft, ob ein gültiges `ParseUser`-Objekt existiert und
  /// der Benutzer durch ein gültiges Session-Token authentifiziert ist. Falls ja,
  /// wird das Benutzerobjekt mit dem aktuellen Status vom Server aktualisiert.
  ///
  /// ### Rückgabewert:
  /// - **[Future<bool>]** : Gibt `true` zurück, wenn der Benutzer eingeloggt ist,
  ///   andernfalls `false`.
  ///
  /// ### Ausnahme:
  /// - Diese Methode wirft keine Ausnahmen, jedoch kann sie `false` zurückgeben,
  ///   falls der Benutzer ausgeloggt wird.
  Future<bool> hasUserLogged() async {
    if (_parseUser != null && _parseUser?.sessionToken != null) {
      final ParseResponse? parseResponse =
          await ParseUser.getCurrentUserFromServer(_parseUser!.sessionToken!);
      if (parseResponse?.success != null &&
          parseResponse!.success &&
          parseResponse.results != null) {
        _parseUser = parseResponse.results!.first;
        return true;
      }
      await _parseUser!.logout();
      //_parseUser = null;
    }
    return false;
  }
}
