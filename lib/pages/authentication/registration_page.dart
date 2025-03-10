import 'dart:async';

import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/authentication/Login_page.dart';
import 'package:fahrschul_manager/pages/home/Home_page.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncRegistrationValidationFormBloc.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();

  Timer? _debounce;

  int _currentPage = 0;
  bool _isLoadingRegistration = false;

  @override
  void dispose() {
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final formBloc = context.read<AsyncRegistrationValidationFormBloc>();
    return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.08),
                          Image.asset(
                            'assets/images/Logo_neu.jpg',
                            height: 100,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.05),
                          Text(
                            "Registrierung",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),
                          SizedBox(
                            height: 430,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (int page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                              children: [
                                _buildFirstPage(formBloc),
                                _buildSecondPage(formBloc),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          _buildPageIndicator(), // Add the page indicator here
                          const SizedBox(height: 16.0),
                          _buildLoginRedirect(context),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
  }

  Widget _buildFirstPage(AsyncRegistrationValidationFormBloc formBloc) {
    return FormBlocListener<AsyncRegistrationValidationFormBloc, String,
            String>(
        onSuccess: (context, state) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        onFailure: (context, state) {
          //TODO
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                showErrorSnackbar(state.failureResponse!, "Fehler FIRST"));
        },
        child: SingleChildScrollView(
          child: Column(children: [
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.fahrschulnameBloc,
              suffixButton: SuffixButton.asyncValidating,
              decoration: inputDecoration('Fahrschulname'),
            ),
            const SizedBox(height: 16.0),
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.plzBloc,
              suffixButton: SuffixButton.asyncValidating,
              decoration: inputDecoration("PLZ"),
              maxLength: 5,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly // Nur Zahlen zulassen
              ],
            ),
            DropdownFieldBlocBuilder(
              selectFieldBloc: formBloc.plzDropDownBloc,
              itemBuilder: (context, value) => FieldItem(
                child: Text(value.get<String>("Name")!),
              ),
              decoration: const InputDecoration(
                labelText: "Stadt wählen",
                prefixIcon: Icon(Icons.house_rounded),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 1),
                ),
                // Optional: Customize the hintText or other properties if needed
              ),
              onChanged: (value) {
                formBloc.plzBloc.updateInitialValue(value!.get<String>("PLZ")!);
                //formBloc.plzDropDownBloc.updateValue(value);
              },
            ),
            const SizedBox(height: 16.0),
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.strasseBloc,
              decoration: inputDecoration('Straße'),
            ),
            const SizedBox(height: 16.0),
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.hausnummerBloc,
              decoration: inputDecoration('Hausnummer'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: formBloc.onSubmittingFirstPage,
              style: stadiumButtonStyle(),
              child: const Text('Weiter'),
            ),
          ]),
        ));
  }

  Widget _buildSecondPage(AsyncRegistrationValidationFormBloc formBloc) {
    return FormBlocListener<AsyncRegistrationValidationFormBloc, String,
        String>(
      formBloc: formBloc,
      onSuccess: (context, state) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>  HomePage()),
          (Route<dynamic> route) => false,
        );
        //Wenn success dann nächste Seite
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(showSuccessSnackbar("Registriert!", "HURA"));
      },
      onFailure: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              showErrorSnackbar(state.failureResponse!, "Fehler SECOND"));
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.vornameBloc,
              decoration: inputDecoration('Vorname'),
            ),
            const SizedBox(height: 16.0),
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.nachnameBloc,
              decoration: inputDecoration('Nachname'),
            ),
            const SizedBox(height: 16.0),
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.emailBloc,
              decoration: inputDecoration('E-Mail'),
              suffixButton: SuffixButton.asyncValidating,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextFieldBlocBuilder(
              textFieldBloc: formBloc.passwordBloc,
              suffixButton: SuffixButton.obscureText,
              decoration: inputDecoration('Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoadingRegistration
                  // ignore: dead_code
                  ? null
                  : () async {
                      try {
                        setState(() {
                          _isLoadingRegistration = true;
                        });
                        await formBloc.onSubmitting();
                      } finally {
                        setState(() {
                          _isLoadingRegistration = false;
                        });
                      }
                    },
              style: stadiumButtonStyle(),
              child: _isLoadingRegistration
                  ? SizedBox(height: 57, child: pacmanLoadingIndicator())
                  : const Text('Registrieren'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          // Animate changes in container properties
          duration: const Duration(milliseconds: 300),
          // Add horizontal spacing between indicators
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          // Make the current page indicator slightly larger
          width: _currentPage == index ? 12.0 : 8.0,
          height: _currentPage == index ? 12.0 : 8.0,
          decoration: BoxDecoration(
            // Highlight current page indicator with blue, others grey
            color: _currentPage == index ? Colors.blue : Colors.grey,
            // Make indicators circular
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildLoginRedirect(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      },
      child: Text.rich(
        const TextSpan(
          text: "Wieder zurück zur Login Seite? ",
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(color: Color(0xFF00BF6D)),
            ),
          ],
        ),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.64),
            ),
      ),
    );
  }
}
