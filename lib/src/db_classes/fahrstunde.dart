import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

//TODO TEST
Future<void> addFahrstunde(
  DateTime datum,
  DateTime zeit,
  String titel, {
  ParseObject? fahrzeug,
  DateTime? endDatum,
  DateTime? endZeit,
  DateTime? pufferZeit,
  ParseObject? fahrschueler,
  String? beschreibung,
}) async {
    if (!Benutzer().isFahrlehrer!) {
      throw ("No permission");
    }

    DateTime dbDate =
        datum.add(Duration(hours: zeit.hour, minutes: zeit.minute));

    final termin = ParseObject("Fahrstunden")
      ..set('Fahrlehrer', Benutzer().dbUser)
      ..set('Titel', titel)
      ..set("Datum", dbDate);

    if (fahrzeug != null) {
      termin.set("Fahrzeug", fahrzeug);
    }
    if (beschreibung != null) {
      termin.set("Beschreibung", beschreibung);
    }

    if (endDatum != null) {
      DateTime dbEndDate =
          endDatum.add(Duration(hours: endZeit!.hour, minutes: endZeit.minute));
      if (pufferZeit != null) {
        dbEndDate = dbEndDate.add(Duration(minutes: pufferZeit.minute));
      }
      termin.set("EndDatum", dbEndDate);
    }

    if (fahrschueler != null) {
      termin.set('Fahrschueler', fahrschueler);
    }

    final ParseResponse response = await termin.save();
    if (!response.success) {
      throw Exception(response.error?.message);
    }
}
