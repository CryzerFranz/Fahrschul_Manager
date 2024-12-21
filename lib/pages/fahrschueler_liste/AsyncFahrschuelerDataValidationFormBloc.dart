// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:fahrschul_manager/doc/intern/Authentication.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Eine FormBloc klasse zur asynchronen Validierung einer Form.
/// Diese gilt für die erste Seite der Registrierung
class AsyncFahrschuelerDataValidationFormBloc extends FormBloc<String, String> {
  // ------------------------Widget list -------------------------
  TextFieldBloc firstNameFormBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie einen Vornamen ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );
  TextFieldBloc lastNameFormBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie einen Nachname ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  TextFieldBloc emailFormBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie einen Nachname ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );
  SelectFieldBloc<ParseObject, String> fahrlehrerDropDownBloc =
      SelectFieldBloc<ParseObject, String>();

  Future<String?> validationEMailExist(String value) async {
    try {
      final bool alreadyExist = await doesUserExist(value);
      if (alreadyExist) {
        return "E-Mail Adresse bereits vergeben";
      }
      return null;
    } catch (e) {
      emitFailure(failureResponse: "Network error");
      return "Netzwerk Fehler";
    }
  }

  /// Konstruktor
  AsyncFahrschuelerDataValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [
      firstNameFormBloc,
      lastNameFormBloc,
      emailFormBloc,
      fahrlehrerDropDownBloc,
    ]);

    emailFormBloc.addAsyncValidators([validationEMailExist]);
  }

  @override
   Future<void> onSubmitting() async {
    // TODO: implement onSubmitting
    try{
      emitSuccess(canSubmitAgain: true);
    }
    catch (e) {
      emitFailure(failureResponse: "Netzwerk fehler");
    } finally {
      reload();
    }
  }
}
