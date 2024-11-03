import 'package:fahrschul_manager/doc/intern/Dummys.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

//TODO TEST
Future<void> addFahrstunde(
  DateTime datum,
  DateTime zeit,
  ParseObject fahrzeug, {
  DateTime? endDatum,
  DateTime? endZeit,
  DateTime? pufferZeit,
  ParseObject? fahrschueler,
  String? titel,
  String? beschreibung,
}) async {
  try {
    //TODO brauche fahrlehrer ParseObject nicht ParseUser (von ParseUser ID suchen in Fahrlehrer, sicher gehen das parseUser Fahrlehrer ist)
    if(!Benutzer().isFahrlehrer!)
    {
      throw("No permission");
    }

    //final fahrlehrer = await getLocalStorageUser();
    //final fahrlehrer = await getFahrlehrerByUserId("hCHGkgyRs9"); //TODO ist nur test
    
    DateTime dbDate =
        datum.add(Duration(hours: zeit.hour, minutes: zeit.minute));
    DateTime? dbEndDate;

    if (endDatum != null) {
      dbEndDate =
          endDatum.add(Duration(hours: endZeit!.hour, minutes: endZeit.minute));
      if (pufferZeit != null) {
        dbEndDate = dbEndDate.add(Duration(minutes: pufferZeit.minute));
      }
    }

    final termin = ParseObject("Fahrstunden")
      ..set('Fahrlehrer', Benutzer().dbUser) //TODO DB ParseObject nicht lokales einfügen
      //..set('Fahrschueler', fahrschueler)
      ..set('Fahrzeug', fahrzeug)
      ..set('Datum', dbDate);
      // ..set('EndDatum', null)
      // ..set('Titel', null)
      // ..set('Beschreibung', null);

    final ParseResponse response = await termin.save();
    if (!response.success) {
      throw Exception(response.error?.message);
    }
  } catch (e) {
    throw Exception("Error: addFahrstunde -> $e");
  }
}
