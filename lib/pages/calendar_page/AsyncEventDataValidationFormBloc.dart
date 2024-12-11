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
      emitSuccess();
    } catch (e) {
      emitFailure(failureResponse: "Netzwerk fehler");
    }
  }

  /// Konstruktor
  AsyncEventDataValidationFormBloc(
      {required String title,
      required DateTime startDateTime,
      required DateTime endDateTime,
      required List<ParseObject> fahrzeuge,
      required List<ParseObject> fahrschueler,
      required bool selectedFahrzeug,
      required bool selectedFahrschueler,
      String? description}) {
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

    startDateTimeFormBloc = InputFieldBloc<DateTime, dynamic>(
        initialValue: startDateTime,
        validators: [
          (selectedDate) {
            if (selectedDate.isBefore(DateTime.now())) {
              return 'Der ausgewählte Datum darf nicht in der Vergangenheut liegen';
            }
            return null;
          },
        ]);

    endDateTimeFormBloc = InputFieldBloc<DateTime, dynamic>(
        initialValue: endDateTime,
        validators: [
          (selectedDate) {
            if (selectedDate.isBefore(DateTime.now())) {
              return 'Der ausgewählte Datum darf nicht in der Vergangenheut liegen';
            }
            if(selectedDate.isBefore(startDateTimeFormBloc.value))
            {
              return "Der ausgewählte Datum darf nicht vor dem Start Datum liegen";
            }
            return null;
          },
        ]);
    // initalValue ist das letzte Element in der Liste. Wird in _fetchData von calendar_page_bloc.dart festgelegt
    fahrzeugDropDownBloc = SelectFieldBloc<ParseObject, String>(
        items: fahrzeuge, initialValue: selectedFahrzeug ? fahrzeuge.last : null);
    fahrschuelerDropDownBloc = SelectFieldBloc<ParseObject, String>(
        items: fahrschueler, initialValue: selectedFahrschueler ? fahrschueler.last : null);

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
