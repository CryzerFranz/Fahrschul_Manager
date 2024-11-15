import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class AsyncFahrschulnameValidationFormBloc extends FormBloc<String, String> {
  final fahrschulname = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      (String? value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie einen Fahrschulnamen ein.';
        }
        return null;
      },
    ],
    asyncValidatorDebounceTime: const Duration(milliseconds: 300),
  );

  @override
  void onSubmitting() async {
    debugPrint(fahrschulname.value);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      emitSuccess();
    } catch (e) {
      emitFailure();
    }
  }

  Future<String?> validationFahrschulName(String value) async{
    bool exist = await checkIfFahrschuleExists(value);
    if(exist)
    {
      return "Fahrschule existiert bereits.";
    }
    return null;
  }

  String? getFahrschulnameValue() {
    return fahrschulname.state.value;
  }

  AsyncFahrschulnameValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [fahrschulname]);

    fahrschulname.addAsyncValidators(
      [validationFahrschulName],
    );
  }
}