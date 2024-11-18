import 'package:fahrschul_manager/src/db_classes/fahrschule.dart';
import 'package:fahrschul_manager/src/db_classes/ort.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Eine FormBloc klasse zur asynchronen Validierung einer Form.
/// Diese gilt für die erste Seite der Registrierung
class AsyncRegistrationFirstPageValidationFormBloc extends FormBloc<String, String> {
  // ------------------------Widget list -------------------------
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

  //------------------------------------------------------------------
  @override
  void onSubmitting() async {
    try {
      fahrschulnameBloc.validate();
      strasseBloc.validate();
      hausnummerBloc.validate();
      fahrschulnameBloc.validate();

      if(plzBloc.value.length < 5 && plzDropDownBloc.value == null)
      {
        plzBloc.addFieldError("Gültige PLZ eingeben oder Stadt auswählen");
        emitFailure();
      }

      if(plzBloc.value.length == 5 && plzDropDownBloc.value == null)
      {
        List<ParseObject> ortObjects = await fetchOrtObjects(plzBloc.value);
        if(ortObjects.isEmpty){
          plzBloc.addFieldError("Gültige PLZ eingeben oder Stadt auswählen");
          emitFailure();
        }
        plzDropDownBloc.updateInitialValue(ortObjects.first);
      }



      // Fahrschulname
      String? validationError =
          await validationFahrschulName(fahrschulnameBloc.value);
      if (validationError != null) {
        fahrschulnameBloc.addFieldError(validationError);
        emitFailure();
      } else {
        emitSuccess();
      }
    } catch (e) {
      emitFailure();
    }
  }

  /// Asynchrone Validierung für die Eingabe den Namen der Fahrschule.
  /// Überprüft während der Eingabe ob die Fahrschule bereits existiert.
  Future<String?> validationFahrschulName(String? value) async {
    if (value == null || value.isEmpty) {
      return 'Bitte geben Sie einen Fahrschulnamen ein.';
    }
    bool exist = await checkIfFahrschuleExists(value);
    if (exist) {
      return "Fahrschule existiert bereits.";
    }
    return null;
  }

  /// Holt sich die Daten von der Datenbank anhand der Eingabe des Benutzers
  Future<String?> validationPLZFetchingOrt(String value) async {
    if(value.length == 5 && plzDropDownBloc.value != null) {
      return null;
    }
    List<ParseObject> ortObjects = await fetchOrtObjects(value);
    if(ortObjects.isEmpty)
    {
      return "Keine gültige PLZ";
    }
    plzDropDownBloc.updateItems(ortObjects);
    return null;

  }

  /// Konstruktor
  AsyncRegistrationFirstPageValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [fahrschulnameBloc, plzBloc, strasseBloc, hausnummerBloc, plzDropDownBloc]);

    fahrschulnameBloc.addAsyncValidators(
      [validationFahrschulName],
    );
    plzBloc.addAsyncValidators(
      [validationPLZFetchingOrt],
    );
  }
}
