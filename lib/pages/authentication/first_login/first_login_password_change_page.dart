import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/Home_page.dart';
import 'package:fahrschul_manager/pages/authentication/first_login/bloc/password_change_bloc.dart';
import 'package:fahrschul_manager/pages/authentication/first_login/bloc/password_change_event.dart';
import 'package:fahrschul_manager/pages/authentication/first_login/bloc/password_change_state.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../../../widgets/loadingIndicator.dart';
import 'AsyncPasswordResetValidationFormBloc.dart';

class FirstLoginPasswordChangePage extends StatelessWidget {
  const FirstLoginPasswordChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<AsyncPasswordResetValidationFormBloc>();
    return FormBlocListener<AsyncPasswordResetValidationFormBloc, String,
            String>(
        onSuccess: (context, state) {
          //Zur Homepage
          context.read<PasswordChangeBloc>().add(ChangePasswordEvent(formBloc.passwordAgainTFFormBloc.value));
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        onFailure: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(showErrorSnackbar(state.failureResponse!, "Fehler"));
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: BlocBuilder<PasswordChangeBloc, PasswordChangeState>(
                builder: (context, state) {
              if (state is ExecutingError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return ScaffoldBody(context, formBloc, state);
              }
            })));
  }

  SingleChildScrollView ScaffoldBody(
      BuildContext context, AsyncPasswordResetValidationFormBloc formBloc, PasswordChangeState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/Logo_neu.jpg', // Lokales Bild aus dem assets-Verzeichnis
              height: 200,
            ),
            const SizedBox(height: 15),
            Text(
              "Willkommen!",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: mainColor),
            ),
            const SizedBox(height: 10),
            Text(
              "Das ist dein erster Login!\nÄndere bitte dein Passwort",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextFieldBlocBuilder(
                textFieldBloc: formBloc.passwordTFFormBloc,
                readOnly: state is Executing ? true : false,
                suffixButton: SuffixButton.obscureText,
                decoration: inputDecoration("Passwort"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextFieldBlocBuilder(
                readOnly: state is Executing ? true : false,
                textFieldBloc: formBloc.passwordAgainTFFormBloc,
                suffixButton: SuffixButton.obscureText,
                decoration: inputDecoration("Gib das Passwort nochmal ein"),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: formBloc.submit,
                style: stadiumButtonStyle(),
                child: state is Executing ? SizedBox(
                                  height: 57, child: pacmanLoadingIndicator())
                              : const Text("Ändern"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
