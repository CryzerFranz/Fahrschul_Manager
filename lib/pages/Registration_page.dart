import 'dart:async';

import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/Home_page.dart';
import 'package:fahrschul_manager/pages/Login_page.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncRegistrationFirstPageValidationFormBloc.dart';
import 'package:fahrschul_manager/src/registration.dart';
import 'package:fahrschul_manager/widgets/decorations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKeySecondPage = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Form field controllers
  final TextEditingController _vornameController = TextEditingController();
  final TextEditingController _nachnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Timer? _debounce;

  int _currentPage = 0;
  bool _isLoadingRegistration = false;



  @override
  void dispose() {
    _vornameController.dispose();
    _nachnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AsyncRegistrationFirstPageValidationFormBloc(),
        child: Builder(builder: (context) {
          final formBloc =
              context.read<AsyncRegistrationFirstPageValidationFormBloc>();
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
        }));
  }

  Widget _buildFirstPage(
      AsyncRegistrationFirstPageValidationFormBloc formBloc) {
    return FormBlocListener<AsyncRegistrationFirstPageValidationFormBloc,
            String, String>(
        onSuccess: (context, state) {
          //Wenn success dann nächste Seite
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        onFailure: (context, state) {
          //TODO
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.failureResponse!)));
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
              onPressed: formBloc.submit,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF00BF6D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const StadiumBorder(),
              ),
              child: const Text('Weiter'),
            ),
          ]),
        ));
  }

  Widget _buildSecondPage(
      AsyncRegistrationFirstPageValidationFormBloc formBloc) {
    return SingleChildScrollView(
      child: Form(
        key: _formKeySecondPage,
        child: Column(
          children: [
            TextFormField(
              controller: _vornameController,
              decoration: inputDecoration('Vorname'),
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, //TODO: Error Message erstellen
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie einen Vornamen ein.';
                }
                if (!RegExp(
                        r'^(?!\s)[A-ZÄÖÜ][a-zäöüß]*(?:[-\s][A-ZÄÖÜ][a-zäöüß]*)*$')
                    .hasMatch(value)) {
                  return 'Nur Buchstaben, Erster Buchstabe groß';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _nachnameController,
              decoration: inputDecoration('Nachname'),
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, //TODO: Error Message erstellen
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie einen Nachnamen ein.';
                }
                if (!RegExp(
                        r'^(?!\s)[A-ZÄÖÜ][a-zäöüß]*(?:[-\s][A-ZÄÖÜ][a-zäöüß]*)*$')
                    .hasMatch(value)) {
                  return 'Nur Buchstaben, Erster Buchstabe groß';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: inputDecoration('E-Mail'),
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, //TODO: Error Message erstellen
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie eine E-Mail ein.';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: inputDecoration('Password'),
              autovalidateMode: AutovalidateMode
                  .onUserInteraction, //TODO: Error Message erstellen
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie ein Password ein.';
                }
                if (!RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}$')
                    .hasMatch(value)) {
                  return 'Mind 8, Groß/klein, Zahl, Sonderzeichen erforderlich';
                }

                return null;
              },
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

                        await fahrschuleRegistration(
                            formBloc.fahrschulnameBloc.value,
                            formBloc.plzDropDownBloc.value!,
                            formBloc.strasseBloc.value,
                            formBloc.hausnummerBloc.value,
                            _emailController.text,
                            _passwordController.text,
                            _vornameController.text,
                            _nachnameController.text);
                        if (await Benutzer().hasUserLogged()) {
                          navigatorKey.currentState?.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          //Fehlerbehandlung wenn der Benutzer nicht eingeloggt ist
                        }
                      } catch (e) {
                        //todo hier muss was passieren
                      } finally {
                        setState(() {
                          _isLoadingRegistration = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF00BF6D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const StadiumBorder(),
              ),
              child: _isLoadingRegistration
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
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
