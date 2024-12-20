import 'dart:async';
import 'package:fahrschul_manager/doc/intern/Fahrzeug.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AsyncFahrzeugAddValidationFormBloc extends FormBloc<String, String> {

  final labelBloc = TextFieldBloc(
    validators: [
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie ein Label ein.';
        }
        if (!RegExp(r'^(?!\s)[A-ZÄÖÜ][a-zäöüß]*(?:[-\s][A-ZÄÖÜ][a-zäöüß]*)*$')
            .hasMatch(value)) {
          return 'Nur Buchstaben, Erster Buchstabe groß';
        }
        return null;
      },
    ],
  );

  final markeDropDownBloc = SelectFieldBloc<ParseObject, String>();
  final typDropDownBloc = SelectFieldBloc<ParseObject, String>();
  final getriebeDropDownBloc = SelectFieldBloc<ParseObject, String>();
  final anhaenger = BooleanFieldBloc();
















  @override
  Future<void> onSubmitting() async{
    try {
      labelBloc.validate();

      bool isValid=await addFahrzeug(
        label: labelBloc.value,
        marke: markeDropDownBloc.value!,
        fahrzeugtyp: typDropDownBloc.value!,
        getriebe: getriebeDropDownBloc.value!,
        anhaengerkupplung: anhaenger.value);
        if (isValid) {
        emitSuccess(canSubmitAgain: true);


       
        
      } else {
        emitFailure(failureResponse: "Session fail");
      }
    } catch (e) {
      emitFailure(failureResponse: e.toString());
    }
    finally{
      reload();
    }
  }


/// Konstruktor
  AsyncFahrzeugAddValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [
      labelBloc,
      markeDropDownBloc,
      typDropDownBloc,
      getriebeDropDownBloc,
      anhaenger,
    ]);
  }
  }