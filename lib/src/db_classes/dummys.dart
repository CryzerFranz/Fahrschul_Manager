//Dummys to quick test without database request (we are poor guys :( ))

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// Fahrschule

final dummyFahrschule_01 = ParseObject("Fahrschule")
  ..set('Name', "Test_Fahrschule_1");

final dummyFahrschule_02 = ParseObject("Fahrschule")
  ..set('Name', "Test_Fahrschule_2");

// Status

final dummyStatusAktiv = ParseObject('Status')..set("Typ", "Aktiv");
final dummyStatusPassiv = ParseObject('Status')..set("Typ", "Passiv");
final dummyStatusNot = ParseObject('Status')..set("Typ", "Nicht zugewiesen");
final dummyStatusEnd = ParseObject('Status')..set("Typ", "Abgeschlossen");

// User

final dummyParseUser_01 =
    ParseUser("luis.schulte@gmail.com", "Test.12345", "luis.schulte@gmail.com");
final dummyParseUser_02 = ParseUser(
    "chris.kloskopf@gmail.com", "Test.12345", "chris.kloskopf@gmail.com");
final dummyParseUser_03 = ParseUser(
    "paleyron.schulte@gmail.com", "Test.12345", "paleyron.schulte@gmail.com");
final dummyParseUser_04 =
    ParseUser("kaka.do@gmail.com", "Test.12345", "kaka.do@gmail.com");
final dummyParseUser_05 =
    ParseUser("mehmet.kanak@gmail.com", "Test.12345", "mehmet.kanak@gmail.com");
final dummyParseUser_06 =
    ParseUser("jonas.bier@gmail.com", "Test.12345", "jonas.bier@gmail.com");
final dummyParseUser_07 =
    ParseUser("tuska.lol@gmail.com", "Test.12345", "tuska.lol@gmail.com");
final dummyParseUser_08 =
    ParseUser("foo.bar@gmail.com", "Test.12345", "foo.bar@gmail.com");
final dummyParseUser_09 =
    ParseUser("lukas.heisi@gmail.com", "Test.12345", "lukas.heisi@gmail.com");

// Fahrschueler

final dummyFahrschueler_01 = ParseObject('Fahrschueler')
  ..set('Name', "Schulte")
  ..set('Vorname', "Luis")
  ..set('Email', "luis.schulte@gmail.com")
  ..set('UserObject', dummyParseUser_01)
  ..set('Gesamtfahrstunden', 0)
  ..set('Status', dummyStatusNot)
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Fahrlehrer', null);

final dummyFahrschueler_02 = ParseObject('Fahrschueler')
  ..set('Name', "mehmet")
  ..set('Vorname', "kanak")
  ..set('Email', "mehmet.kanak@gmail.com")
  ..set('UserObject', dummyParseUser_05)
  ..set('Gesamtfahrstunden', 0)
  ..set('Status', dummyStatusAktiv)
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Fahrlehrer', dummyFahrlehrer_01);

final dummyFahrschueler_03 = ParseObject('Fahrschueler')
  ..set('Name', "jonas")
  ..set('Vorname', "bier")
  ..set('Email', "jonas.bier@gmail.com")
  ..set('UserObject', dummyParseUser_06)
  ..set('Gesamtfahrstunden', 50)
  ..set('Status', dummyStatusAktiv)
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Fahrlehrer', dummyFahrlehrer_01);

final dummyFahrschueler_04 = ParseObject('Fahrschueler')
  ..set('Name', "tuska")
  ..set('Vorname', "lol")
  ..set('Email', "tuska.lol@gmail.com")
  ..set('UserObject', dummyParseUser_07)
  ..set('Gesamtfahrstunden', 0)
  ..set('Status', dummyStatusPassiv)
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Fahrlehrer', dummyFahrlehrer_01);

// Fahrlehrer
final dummyFahrlehrer_01 = ParseObject('Fahrlehrer')
  ..set('Name', "chris")
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Vorname', "kloskopf")
  ..set('Email', "chris.kloskopf@gmail.com")
  ..set('UserObject', dummyParseUser_02);

final dummyFahrlehrer_02 = ParseObject('Fahrlehrer')
  ..set('Name', "paleyron")
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Vorname', "schulte")
  ..set('Email', "paleyron.schulte@gmail.com")
  ..set('UserObject', dummyParseUser_03);

final dummyFahrlehrer_03 = ParseObject('Fahrlehrer')
  ..set('Name', "kaka")
  ..set('Fahrschule', dummyFahrschule_02)
  ..set('Vorname', "do")
  ..set('Email', "kaka.do@gmail.com")
  ..set('UserObject', dummyParseUser_04);

// Ort

final dummyOrtForchheim = ParseObject("Ort")
  ..set("Name", "Forchheim")
  ..set("PLZ", "91301");

final dummyOrtErlangen = ParseObject("Ort")
  ..set("Name", "Erlangen")
  ..set("PLZ", "91052");

final dummyOrtBamberg = ParseObject("Ort")
  ..set("Name", "Bamberg")
  ..set("PLZ", "96047");

// Zuordnung_Ort_Fahrschule

// ignore: non_constant_identifier_names
final dummyFahrschule_01_ort_01 = ParseObject('Zuordnung_Ort_Fahrschule')
  ..set('Ort', dummyOrtForchheim)
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Strasse', "Neuenberg")
  ..set('Hausnummer', "21");

// ignore: non_constant_identifier_names
final dummyFahrschule_01_ort_02 = ParseObject('Zuordnung_Ort_Fahrschule')
  ..set('Ort', dummyOrtForchheim)
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Strasse', "BambergerStr")
  ..set('Hausnummer', "99");

// ignore: non_constant_identifier_names
final dummyFahrschule_01_ort_03 = ParseObject('Zuordnung_Ort_Fahrschule')
  ..set('Ort', dummyOrtBamberg)
  ..set('Fahrschule', dummyFahrschule_01)
  ..set('Strasse', "berlinerRing")
  ..set('Hausnummer', "50a");

// ignore: non_constant_identifier_names
final dummyFahrschule_02_ort_01 = ParseObject('Zuordnung_Ort_Fahrschule')
  ..set('Ort', dummyOrtErlangen)
  ..set('Fahrschule', dummyFahrschule_02)
  ..set('Strasse', "talahonstr")
  ..set('Hausnummer', "88a");


// Marke

final dummySeat = ParseObject("Marke")
  ..set('Name', "Seat");

final dummyRenault = ParseObject("Marke")
  ..set('Name', "Renault");

final dummyAudi = ParseObject("Marke")
  ..set('Name', "Audi");

// Getriebe

final dummySchalter = ParseObject("Getriebe")
  ..set('Typ', "Manuell");

final dummyAutomatik = ParseObject("Getriebe")
  ..set('Typ', "Automatik");

// Fahrzeugtyp

final dummyLimousine = ParseObject("Fahrzeugtyp")
  ..set('Typ', "Limousine");

final dummyKombi = ParseObject("Fahrzeugtyp")
  ..set('Typ', "Kombi");
