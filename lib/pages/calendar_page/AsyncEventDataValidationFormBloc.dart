// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Eine FormBloc klasse zur asynchronen Validierung einer Form.
/// Diese gilt für die erste Seite der Registrierung
class AsyncEventDataValidationFormBloc extends FormBloc<String, String> {
  // ------------------------Widget list -------------------------
  late TextFieldBloc titleFormBloc;
  late TextFieldBloc descriptionFormBloc;
  late InputFieldBloc<DateTime, dynamic> startDateTimeFormBloc;
  late InputFieldBloc<DateTime, dynamic> endDateTimeFormBloc;
  late SelectFieldBloc<ParseObject, String> fahrzeugDropDownBloc;
  late SelectFieldBloc<ParseObject, String> fahrschuelerDropDownBloc;

  //------------------------------------------------------------------
  @override
  Future<void> onSubmitting() async {
    try {
      ////validieren
      //emailTFFormBloc.validate();
      //passwordTFFormBloc.validate();

      //bool isValid = await Benutzer()
      //    .login(emailTFFormBloc.value.trim(), passwordTFFormBloc.value.trim());
      //if(isValid)
      //{
      //  emitSuccess();
      //}
      //else{
      //  emailTFFormBloc.addFieldError("Angegebene Daten sind Falsch.");
      //  passwordTFFormBloc.addFieldError("Angegebene Daten sind Falsch.");
      //  emitFailure(failureResponse: "Falsche Daten");
      //}
    } catch (e) {
      emitFailure(failureResponse: "Netzwerk fehler");
    }
  }

  /// Konstruktor
  AsyncEventDataValidationFormBloc({required String title, required DateTime startDateTime, required DateTime endDateTime, required List<ParseObject> fahrzeuge, required List<ParseObject> schueler ,String? description}) {
    titleFormBloc = TextFieldBloc(
      initialValue: title,
      validators: [
        (String? value) {
          if (value == null || value.isEmpty) {
            return 'Bitte geben Sie einen Titel ein.';
          }
          return null;
        },
      ],
      asyncValidatorDebounceTime: const Duration(milliseconds: 300),
    );

    descriptionFormBloc = TextFieldBloc(initialValue: description ?? "");

    startDateTimeFormBloc = 
      InputFieldBloc<DateTime, dynamic>(initialValue: startDateTime, validators: [
    (selectedDate) {
      if (selectedDate.isBefore(DateTime.now())) {
        return 'Der ausgewählte Datum darf nicht in der Vergangenheut liegen';
      }
      return null;
    },
  ]);

  endDateTimeFormBloc = 
      InputFieldBloc<DateTime, dynamic>(initialValue: endDateTime, validators: [
    (selectedDate) {
      if (selectedDate.isBefore(DateTime.now())) {
        return 'Der ausgewählte Datum darf nicht in der Vergangenheut liegen';
      }
      return null;
    },
  ]);

  fahrzeugDropDownBloc = SelectFieldBloc<ParseObject, String>(items: fahrzeuge);
  fahrschuelerDropDownBloc = SelectFieldBloc<ParseObject, String>(items: schueler);

    addFieldBlocs(fieldBlocs: [
      titleFormBloc,
      descriptionFormBloc,
      startDateTimeFormBloc,
      endDateTimeFormBloc,
      fahrzeugDropDownBloc,
      fahrschuelerDropDownBloc
    ]);
  }
}
