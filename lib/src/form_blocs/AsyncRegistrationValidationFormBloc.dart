import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/Home_page.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschule.dart';
import 'package:fahrschul_manager/src/db_classes/ort.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/src/registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Eine FormBloc klasse zur asynchronen Validierung einer Form.
/// Diese gilt für die erste Seite der Registrierung
class AsyncRegistrationValidationFormBloc extends FormBloc<String, String> {
  // ------------------------Widget list -------------------------
  // Variablen firstPage
  final fahrschulnameBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie einen Fahrschulnamen ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  final strasseBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie eine Strasse ein.';
        }
        return null;
      },
    ],
  );

  final hausnummerBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie eine Hausnummer ein.';
        }
        return null;
      },
    ],
  );

  final plzBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie eine PLZ ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  final plzDropDownBloc = SelectFieldBloc<ParseObject, String>();

//Variablen secondPage

  final vornameBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie einen Vornamen ein.';
        }
        if (!RegExp(r'^(?!\s)[A-ZÄÖÜ][a-zäöüß]*(?:[-\s][A-ZÄÖÜ][a-zäöüß]*)*$')
            .hasMatch(value)) {
          return 'Nur Buchstaben, Erster Buchstabe groß';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  final nachnameBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie einen Nachnamen ein.';
        }
        if (!RegExp(r'^(?!\s)[A-ZÄÖÜ][a-zäöüß]*(?:[-\s][A-ZÄÖÜ][a-zäöüß]*)*$')
            .hasMatch(value)) {
          return 'Nur Buchstaben, Erster Buchstabe groß';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  final emailBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie eine E-Mail ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  final passwordBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie ein Password ein.';
        }
        if (!RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}$')
            .hasMatch(value)) {
          return 'Mind 8, Groß/klein, Zahl, Sonderzeichen erforderlich';
        }

        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  //------------------------------------------------------------------

  @override
  Future<void> onSubmitting() async {
    try {
      vornameBloc.validate();
      nachnameBloc.validate();
      emailBloc.validate();
      passwordBloc.validate();

      await fahrschuleRegistration(
          fahrschulName: fahrschulnameBloc.value,
          ortObject: plzDropDownBloc.value!,
          strasse: strasseBloc.value,
          hausnummer: hausnummerBloc.value,
          eMail: emailBloc.value,
          password: passwordBloc.value,
          vorname: vornameBloc.value,
          name: nachnameBloc.value);
      if (await Benutzer().hasUserLogged()) {
        //TODO Auf fehler Überprüfen
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
        
      } else {
        emitFailure(failureResponse: "Login Fail");
      }
    } catch (e) {
      emitFailure(failureResponse: e.toString());
    }
  }

  void onSubmittingFirstPage() async {
    try {
      fahrschulnameBloc.validate();
      strasseBloc.validate();
      hausnummerBloc.validate();
      fahrschulnameBloc.validate();

      if (plzBloc.value.length < 5 && plzDropDownBloc.value == null) {
        plzBloc.addFieldError("Gültige PLZ eingeben oder Stadt auswählen");
        emitFailure(
            failureResponse: "Gültige PLZ eingeben oder Stadt auswählen");
      }

      if (plzBloc.value.length == 5 && plzDropDownBloc.value == null) {
        List<ParseObject> ortObjects = await fetchOrtObjects(plzBloc.value);
        if (ortObjects.isEmpty) {
          plzBloc.addFieldError("Gültige PLZ eingeben oder Stadt auswählen");
          emitFailure(
              failureResponse: "Gültige PLZ eingeben oder Stadt auswählen");
        }
        plzDropDownBloc.changeValue(ortObjects.first);
      }

      // Fahrschulname
      String? validationError =
          await validationFahrschulName(fahrschulnameBloc.value);
      if (validationError != null) {
        fahrschulnameBloc.addFieldError(validationError);
        emitFailure(failureResponse: validationError);
      } else {
        emitSuccess(canSubmitAgain: true);
      }
    } catch (e) {
      emitFailure(failureResponse: e.toString());
    }
  }

  /// Asynchrone Validierung für die Eingabe den Namen der Fahrschule.
  /// Überprüft während der Eingabe ob die Fahrschule bereits existiert.
  Future<String?> validationFahrschulName(String? value) async {
    try {
      if (value == null || value.isEmpty) {
        return 'Bitte geben Sie einen Fahrschulnamen ein.';
      }
      bool exist = await checkIfFahrschuleExists(value);
      if (exist) {
        return "Fahrschule existiert bereits.";
      }
    } catch (e) {
      emitFailure(failureResponse: "Network error");
    } finally {
      return null;
    }
  }

  /// Holt sich die Daten von der Datenbank anhand der Eingabe des Benutzers
  Future<String?> validationPLZFetchingOrt(String value) async {
    try {
      if (value.length == 5 && plzDropDownBloc.value != null) {
        return null;
      }
      List<ParseObject> ortObjects = await fetchOrtObjects(value);
      if (ortObjects.isEmpty) {
        return "Keine gültige PLZ";
      }
      plzDropDownBloc.updateItems(ortObjects);
      //Falls PLZ vollständig eingegeben dann update denn ausgewählt wert vom DropDownMenu.
      //Ansonsten kommt ein DropDownMenu error beim submitting
      if (value.length == 5 && plzDropDownBloc.value == null) {
        plzDropDownBloc.updateValue(ortObjects.first);
      }
    } catch (e) {
      emitFailure(failureResponse: "Network error");
    }
    finally{
      return null;
    }
  }

  Future<String?> validationEMailExist(String value) async {
    try{
    final bool alreadyExist = await doesUserExist(value);
    if (alreadyExist) {
      return "E-Mail Adresse bereits vergeben";
    }
    }catch(e){
        emitFailure(failureResponse: "Network error");
    }finally{
      return null;
    }
  }

  /// Konstruktor
  AsyncRegistrationValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [
      fahrschulnameBloc,
      plzBloc,
      strasseBloc,
      hausnummerBloc,
      plzDropDownBloc,
      vornameBloc,
      nachnameBloc,
      emailBloc,
      passwordBloc
    ]);

    /// Asynchrone Validierung hinzufügen
    fahrschulnameBloc.addAsyncValidators(
      [validationFahrschulName],
    );
    plzBloc.addAsyncValidators(
      [validationPLZFetchingOrt],
    );
    emailBloc.addAsyncValidators([validationEMailExist]);
  }
}
