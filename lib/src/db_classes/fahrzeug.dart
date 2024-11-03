import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


//TODO TEST
/// Fügt ein Fahrzeug zur Fahrschule hinzu
Future<void> addFahrzeug(String getriebe, String fahrzeugtyp, String marke, {String? label, bool anhaengerkupplung = false}) async{
  try{
    final fahrschuleObj = Benutzer().fahrschule;
    if(fahrschuleObj == null)
    {
      throw Exception("Invalid User");
    }
    final getriebeObj = await getGetriebe(getriebe);
    final fahrzeugtypObj = await getFahrzeugtyp(fahrzeugtyp);
    final markeObj = await getMarke(marke);
    if(getriebeObj == null || fahrzeugtypObj == null || markeObj == null)
    {
      throw Exception("Null values not allowed for: Getriebe ($getriebe); Fahrzeugtyp ($fahrzeugtyp); Marke ($marke)");
    }
    final user = Benutzer().parseUser;
    if(user == null)
    {
      throw("no user");
      //return;
    }
    
    final fahrzeugObject = ParseObject("Fahrzeug")
    ..set('Getriebe', getriebeObj)
    ..set('Fahrzeugtyp', fahrzeugtypObj)
    ..set('Marke', markeObj)
    ..set('Label', label)
    ..set('Anhaengerkupplung', anhaengerkupplung)
    ..set('Fahrschule', fahrschuleObj);

  final ParseResponse response = await fahrzeugObject.save();
  if(!response.success)
  {
    throw Exception(response.error?.message);
  }
  }catch(e)
  {
    throw(Exception("Error: addFahrzeug -> $e"));
  }

}

/// Erhalte einen ParseObject von `Getriebe`.
/// 
/// ### Parameters:
/// 
/// - **`String` [typ]** : Bezeichnung des Getriebes.
/// 
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
/// 
/// ### Exception:
/// - **[Exception]** 
Future<ParseObject?> getGetriebe(final String typ) async
{
  try{
    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Getriebe'))
    ..whereContains('Typ', typ);

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
  }catch(e)
  {
    throw Exception("Error: getGetriebe -> $e");
  }
}

/// Erhalte einen ParseObject von `Marke`.
/// 
/// ### Parameters:
/// 
/// - **`String` [name]** : Name der Marke.
/// 
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
/// 
/// ### Exception:
/// - **[Exception]** 
Future<ParseObject?> getMarke(final String name) async
{
  try{
    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Marke'))
    ..whereContains('Name', name);

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
  } catch(e)
  {
    throw Exception("Error: getMarke -> $e");
  }
}

/// Erhalte einen ParseObject von `Fahrzeugtyp`.
/// 
/// ### Parameters:
/// 
/// - **`String` [typ]** : Bezeichnung des Fahrzeugtyps.
/// 
/// ### Return value:
/// - **[ParseObject?]** : `ParseObject` || `null`
/// 
/// ### Exception:
/// - **[Exception]** 
Future<ParseObject?> getFahrzeugtyp(final String typ) async
{
  try{
    final QueryBuilder<ParseObject> parseQuery = QueryBuilder<ParseObject>(ParseObject('Fahrzeugtyp'))
    ..whereContains('Typ', typ);

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
  }catch(e)
  {
    throw Exception("Error: getFahrzeugtyp -> $e");
  }
}