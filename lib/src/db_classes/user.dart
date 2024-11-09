import 'package:fahrschul_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// TEST singleton klasse

/// Die `Benutzer`-Klasse verwaltet die Benutzerauthentifizierung und die Benutzerrolle
/// innerhalb der Anwendung. Sie implementiert ein Singleton-Muster, um sicherzustellen,
/// dass nur eine Instanz der Klasse während der gesamten Lebensdauer der Anwendung
/// existiert.
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

  Future<void> clear() async {
     _isLogged = false;
    _isFahrlehrer = null;
    _fahrschule = null;
    _dbUser = null;
    _parseUser = null;
  }

  void _clearNavigator() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              MyApp()), //TODO: Anstatt MyApp() sollte LoginPage() sein.
      (Route<dynamic> route) => false,
    );
  }

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

  Future<bool> _initUserSetup() async{
    if(_parseUser == null || _isLogged != true)
    {
      return false;
    }
    _isFahrlehrer = await _checkIsUserFahrlehrer();
    if(!await _setUser())
    {
      await clear();
      return false;
    }
    _fahrschule = _dbUser!.get<ParseObject>('Fahrschule');
    return true;
  }

  Future<bool> login(final String eMail, final String password) async {
    _parseUser = ParseUser(eMail, password, eMail);
    final response = await _parseUser!.login();
    if(response.success){
      _isLogged = true;
      return await _initUserSetup();
    }
    return false;
  }

//TODO
  Future<void> updateAll() async {
    _isLogged = false;
    await hasUserLogged();
  }

  Future<List<ParseObject>> getAllFahrschueler() async
  {
    if(_isFahrlehrer == null || _dbUser == null)
    {
      throw("Invalid User");
    }
    if(!_isFahrlehrer!)
    {
        throw("Permission denied");
    }

    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Fahrschueler'))
    ..whereContains('Fahrlehrer', dbUserId!);

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

  Future<bool> _checkIsUserFahrlehrer() async {
    List<ParseObject> roleList = await getUserRoles();
    for (var roles in roleList) {
      if (roles.get<String>('name') == "Fahrlehrer") {
        return true;
      }
    }
    return false;
  }

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
          return await _initUserSetup();
        }
        return true;
      }
      await logout();
      //_parseUser = null;
    }
    return false;
  }
}
