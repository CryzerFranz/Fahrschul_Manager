import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// Eine FormBloc klasse zur asynchronen Validierung einer Form.
/// Diese gilt für die erste Seite der Registrierung
class AsyncLoginValidationFormBloc extends FormBloc<String, String> {
  // ------------------------Widget list -------------------------
  final emailTFFormBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie eine E-Mail Addresse ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

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

  //------------------------------------------------------------------
  @override
  Future<void> onSubmitting() async {
    try {
      //validieren
      emailTFFormBloc.validate();
      passwordTFFormBloc.validate();

      bool isValid = await Benutzer()
          .login(emailTFFormBloc.value.trim(), passwordTFFormBloc.value.trim());
      if(isValid)
      {
        emitSuccess();
      }
      else{
        emailTFFormBloc.addFieldError("Angegebene Daten sind Falsch.");
        passwordTFFormBloc.addFieldError("Angegebene Daten sind Falsch.");
        emitFailure(failureResponse: "Falsche Daten");
      }
    } catch (e) {
      emitFailure(failureResponse: "Netzwerk fehler");
    }
  }

  /// Konstruktor
  AsyncLoginValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [emailTFFormBloc, passwordTFFormBloc]);

    /// Asynchrone Validierung hinzufügen
    //fahrschulnameBloc.addAsyncValidators(
    //  [validationFahrschulName],
    //);
  }
}
