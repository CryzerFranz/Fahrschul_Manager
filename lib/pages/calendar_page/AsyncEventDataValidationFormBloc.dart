// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Eine FormBloc klasse zur asynchronen Validierung einer Form.
/// Diese gilt für die erste Seite der Registrierung
class AsyncEventDataValidationFormBloc extends FormBloc<String, String> {
  // ------------------------Widget list -------------------------
  TextFieldBloc titleFormBloc  = TextFieldBloc(
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

  TextFieldBloc descriptionFormBloc  = TextFieldBloc();

   InputFieldBloc<DateTime, dynamic> startDateTimeFormBloc = InputFieldBloc<DateTime, dynamic>(
        initialValue: DateTime.now(),
        validators: [
          (selectedDate) {
            if (selectedDate.isBefore(DateTime.now())) {
              return 'Der ausgewählte Datum darf nicht in der Vergangenheut liegen';
            }
            return null;
          },
        ]);

  InputFieldBloc<DateTime, dynamic> endDateTimeFormBloc = InputFieldBloc<DateTime, dynamic>(
        initialValue: DateTime.now(),
        validators: [
          (selectedDate) {
            if (selectedDate.isBefore(DateTime.now())) {
              return 'Der ausgewählte Datum darf nicht in der Vergangenheut liegen';
            }
            // if(selectedDate.isBefore(startDateTimeFormBloc.value))
            // {
              // return "Der ausgewählte Datum darf nicht vor dem Start Datum liegen";
            // }
            return null;
          },
        ]);
  SelectFieldBloc<ParseObject, String> fahrzeugDropDownBloc = SelectFieldBloc<ParseObject, String>();
  SelectFieldBloc<ParseObject, String> fahrschuelerDropDownBloc = SelectFieldBloc<ParseObject, String>();

  //------------------------------------------------------------------
  @override
  Future<void> onSubmitting() async {
    try {
      emitSuccess();
    } catch (e) {
      emitFailure(failureResponse: "Netzwerk fehler");
    }
  }

  /// Konstruktor
  AsyncEventDataValidationFormBloc() {

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
