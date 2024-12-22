import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/authentication/Registration_page.dart';
import 'package:fahrschul_manager/pages/authentication/first_login/first_login_password_change_page.dart';
import 'package:fahrschul_manager/pages/home/Home_page.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncLoginValidationFormBloc.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SignInPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<AsyncLoginValidationFormBloc>();
    return loginPageScaffold(formBloc);
  }

  FormBlocListener loginPageScaffold(AsyncLoginValidationFormBloc formBloc) {
    return FormBlocListener<AsyncLoginValidationFormBloc, String, String>(
      onSuccess: (context, state) {
        //Überprüfen ob es sich um den ersten Login bei dem Nutzer handelt
        if (Benutzer().parseUser!.get<bool>("firstSession")!) {
          // Passwort neusetzen lassen
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
                builder: (context) => FirstLoginPasswordChangePage()),
          );
        } else {
          //Zur Homepage
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      },
      onFailure: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(showErrorSnackbar(state.failureResponse!, "Fehler"));
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.1),
                    Image.asset(
                      'assets/images/Logo_neu.jpg', // Lokales Bild aus dem assets-Verzeichnis
                      height: 200,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.1),
                    Text(
                      "Login",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    Column(
                      children: [
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.emailTFFormBloc,
                          readOnly: _isLoading,
                          decoration: inputDecoration('E-Mail'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFieldBlocBuilder(
                            textFieldBloc: formBloc.passwordTFFormBloc,
                            readOnly: _isLoading,
                            suffixButton: SuffixButton.obscureText,
                            decoration: inputDecoration("Password"),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await formBloc.onSubmitting();
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                          style: stadiumButtonStyle(),
                          child: _isLoading
                              ? SizedBox(
                                  height: 57, child: pacmanLoadingIndicator())
                              : const Text("Einloggen"),
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                  builder: (context) => RegistrationPage()),
                            );
                          },
                          child: Text.rich(
                            const TextSpan(
                              text: "Neue Fahrschule registrieren? ",
                              children: [
                                TextSpan(
                                  text: "Registrieren",
                                  style: TextStyle(color: Color(0xFF00BF6D)),
                                ),
                              ],
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withOpacity(0.64),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
