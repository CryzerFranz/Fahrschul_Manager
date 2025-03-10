import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// Eine FormBloc klasse zur asynchronen Validierung einer Form.
/// Diese gilt für die erste Seite der Registrierung
class AsyncPasswordResetValidationFormBloc extends FormBloc<String, String> {
  // ------------------------Widget list -------------------------
  final passwordTFFormBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie ein Passwort ein.';
        }
        return null;
      },
    ],
  );

  final passwordAgainTFFormBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie ein Passwort ein.';
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
      emitSuccess();
    } catch (e) {
      emitFailure(failureResponse: "Netzwerk fehler");
    }
  }

  Future<String?> validationPasswordConsistent(String? value) async {
      if (value == null || value.isEmpty) {
        return 'Gib das passende Passwort ein.';
      }
      if (value != passwordTFFormBloc.value) {
        return "Passwort ist nicht übereinstimmend";
      }
      return null;
  }


  /// Konstruktor
  AsyncPasswordResetValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [passwordAgainTFFormBloc, passwordTFFormBloc]);

    /// Asynchrone Validierung hinzufügen
    //fahrschulnameBloc.addAsyncValidators(
    //  [validationFahrschulName],
    //);
    passwordAgainTFFormBloc.addAsyncValidators([validationPasswordConsistent]);
  }
}
