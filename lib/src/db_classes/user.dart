import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Status.dart';
import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/authentication/Login_page.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Die `Benutzer`-Klasse verwaltet die Benutzerauthentifizierung und die Benutzerrolle
/// innerhalb der Anwendung. Sie implementiert ein Singleton-Muster, um sicherzustellen,
/// dass nur eine Instanz der Klasse während der gesamten Lebensdauer der Anwendung
/// existiert.
class Benutzer {

  Benutzer._internal();

  static final Benutzer _instance = Benutzer._internal();

  factory Benutzer() => _instance;

  bool _isLogged = false;
  bool? _isFahrlehrer = false;
  ParseObject? _fahrschule;
  ParseObject? _dbUser;
  ParseUser? _parseUser;

  bool? get isFahrlehrer => _isFahrlehrer;
  ParseObject? get fahrschule => _fahrschule;
  ParseUser? get parseUser => _parseUser;
  ParseObject? get dbUser => _dbUser;
  String? get dbUserId => _dbUser?.objectId;

  void initialize() {
    _isLogged = false;
    _isFahrlehrer = null;
    _fahrschule = null;
    _dbUser = null;
    _parseUser = null;
  }

  Future<bool> _setUser() async {
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
        return true;
      }
    }
    return false;
  }

  /// Instanz zurücksetzen
  Future<void> clear() async {
     _isLogged = false;
    _isFahrlehrer = null;
    _fahrschule = null;
    _dbUser = null;
    _parseUser = null;
  }

  /// Benutzer zur Login-Seite zurückführen und den Navigator leeren bis auf die Login-Seite
  void _clearNavigator() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              SignInPage()),
      (Route<dynamic> route) => false,
    );
  }

  /// Ausloggen des Benutzers
  /// 
  /// ### Return value:
  /// - **[bool]** : `true` wenn der Benutzer erfolgreich ausgeloggt wurde. Andernfalls `false`.
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

  /// Die Variablen werden hierüber gesetzt
  Future<bool> _initUserSetup() async{
    if(_parseUser == null || _isLogged != true)
    {
      return false;
    }
    _isFahrlehrer = await _checkIsUserFahrlehrer();
    final isUserSet = await _setUser();
    if(!isUserSet)
    {
      await clear();
      return false;
    }
    _fahrschule = _dbUser!.get<ParseObject>('Fahrschule');
    return true;
  }

  /// Einloggen des Benutzers
  /// 
  /// ### Parameters
  /// - **`String` [eMail]** : E-Mail addresse des Benutzers
  /// - **`String` [password]** : Passwort des Benutzers
  /// 
  /// ### Return value:
  /// - **[bool]** : `true` wenn der Benutzer erfolgreich eingeloggt wurde. Andernfalls `false`.
  Future<bool> login(final String eMail, final String password) async {
    _parseUser = ParseUser(eMail, password, eMail);
    final response = await _parseUser!.login();
    if(response.success){
      _isLogged = true;
      final isUserSet = await _initUserSetup();
      return isUserSet;
    }
    return false;
  }

//TODO
  Future<void> updateAll() async {
    _isLogged = false;
    await hasUserLogged();
  }

  /// Gibt die Fahrschueler mit den übergebenen Status zurück
  /// 
  /// ### Parameter:
  /// - **`String` [state]** : Status der Fahrschueler
  /// 
  /// ### Return value:
  /// - **[List<ParseObject>]** : Eine Liste wo alle zugehörigen Fahrschüler sind
  Future<List<ParseObject>> fetchFahrschuelerByState({required String state}) async
  {
    if(_isFahrlehrer == null || _dbUser == null)
    {
      throw("Invalid User");
    }
    if(!_isFahrlehrer!)
    {
        throw("Permission denied");
    }

    final String? stateId = await fetchStatusID(state);
    if(stateId == null)
    {
      throw("Status existiert nicht.");
    }

    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Fahrschueler'))
    ..whereContains('Fahrschule', Benutzer().fahrschule!.objectId!)
    ..whereContains('Status', stateId);

    if(state != stateUnassigned)
    {
      parseQuery.whereContains('Fahrlehrer', dbUserId!);
    }

    final apiResponse = await parseQuery.query();

    if (!apiResponse.success) 
    {
      throw Exception(apiResponse.error?.message);
    }
    if(apiResponse.results == null)
    {
      return [];
    }

    return apiResponse.results as List<ParseObject>;
  }


  Future<int?> countFahrschuelerByState({required String state}) async
  {
    if(_isFahrlehrer == null || _dbUser == null)
    {
      throw("Invalid User");
    }
    if(!_isFahrlehrer!)
    {
        throw("Permission denied");
    }

    final String? stateId = await fetchStatusID(state);
    if(stateId == null)
    {
      throw("Status existiert nicht.");
    }

    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Fahrschueler'))
    ..whereContains('Fahrschule', Benutzer().fahrschule!.objectId!)
    ..whereContains('Status', stateId);

    if(state != stateUnassigned)
    {
      parseQuery.whereContains('Fahrlehrer', dbUserId!);
    }

    final apiResponse = await parseQuery.count();

    if (!apiResponse.success) 
    {
      throw Exception(apiResponse.error?.message);
    }
    if(apiResponse.results == null)
    {
      return null ;
    }

    return apiResponse.count;
  } 

  /// Überprüft ob der eingeloggte User ein Fahrlehrer ist
  /// 
  /// ### Return value:
  /// - **[bool]** : `true` wenn der eingeloggte Benutzer ein Fahrlehrer ist.
  Future<bool> _checkIsUserFahrlehrer() async {
    List<ParseObject> roleList = await getUserRoles();
    for (var roles in roleList) {
      if (roles.get<String>('name') == "Fahrlehrer") {
        return true;
      }
    }
    return false;
  }

  /// Updaten des ParseUsers
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

  /// Gibt die Rollen des eingeloggten Benutzers zurück
  ///   /// ### Return value:
  /// - **[List<ParseObject>]** : Eine Liste wo alle zugehörigen Rollen sind
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

  /// Überprüft ob der Benutzer eine aktive Session besitzt bzw. bereits eingeloggt ist
  /// 
  /// ### Return value:
  /// - **[bool]** : `true` wenn der Benutzer lokal & remote noch angemeldet ist ( gültige session). 
  Future<bool> hasUserLogged() async {
    _parseUser = await ParseUser.currentUser() as ParseUser?;
    if (_parseUser != null && _parseUser?.sessionToken != null) {
      final ParseResponse? parseResponse =
          await ParseUser.getCurrentUserFromServer(_parseUser!.sessionToken!);
      if (parseResponse?.success != null &&
          parseResponse!.success &&
          parseResponse.results != null) {
        _parseUser = parseResponse.results!.first;
        if(!_isLogged){
          _isLogged = true;
          final isInit = await _initUserSetup();
          return isInit;
        }
        return true;
      }
      await logout();
      //_parseUser = null;
    }
    return false;
  }
}
