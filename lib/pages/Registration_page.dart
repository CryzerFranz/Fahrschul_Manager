import 'dart:async';
import 'dart:math';

import 'package:async_searchable_dropdown/async_searchable_dropdown.dart';
import 'package:fahrschul_manager/doc/intern/Authentication.dart';
import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:fahrschul_manager/doc/intern/Ort.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/Home_page.dart';
import 'package:fahrschul_manager/pages/Login_page.dart';
import 'package:fahrschul_manager/widgets/decorations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKeyFirstPage = GlobalKey<FormState>();
  final _formKeySecondPage = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Form field controllers
  final TextEditingController _fahrschulnameController =
      TextEditingController();
  final TextEditingController _ortController = TextEditingController();
  final TextEditingController _strasseController = TextEditingController();
  final TextEditingController _hausnummerController = TextEditingController();
  final TextEditingController _vornameController = TextEditingController();
  final TextEditingController _nachnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessageOrt = null;
  String? _errorMessageFahrschulname = null;
  Timer? _debounce;

  List<ParseObject> _results = [];
  ParseObject? _ort;

  int _currentPage = 0; // Variable to track the current page

  void _onSearchChanged() {
    if (_ortController.text.length >= 3) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        _fetchOrtData(_ortController.text);

        
        if (_ortController.text.length == 5) {
          if (_results.isEmpty) {
            setState(() {
              _ort = null;
            });
          } else {
            
            for (var result in _results) {
              if (result.get<String>('PLZ') == _ortController.text) {
                setState(() {
                  _ort = result;
                });
                break;
              }
            }
          }
        }
      });
    } else {
      setState(() {
        _results.clear();
      });
    }
  }

  // Abrufen der Daten von Parse
  Future<void> _fetchOrtData(String plz) async {
    try {
      List<ParseObject> ortObjects = await fetchOrtObjects(plz);
      setState(() {
        // Extrahiere Städtenamen und fülle _results
        _results = ortObjects;
      });
    } catch (e) {
      print("Fehler beim Abrufen der Daten: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _ortController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _fahrschulnameController.dispose();
    _ortController.dispose();
    _strasseController.dispose();
    _hausnummerController.dispose();
    _vornameController.dispose();
    _nachnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    _errorMessageOrt =
        null; // Reset the error message when the widget is disposed
    _errorMessageFahrschulname = null;
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                      height: 400,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          _buildFirstPage(),
                          _buildSecondPage(),
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

  Widget _buildFirstPage() {
    return BlocProvider(
        create: (context) => AsyncFahrschulnameValidationFormBloc(),
        child: Builder(builder: (context) {
          final formBloc = context.read<AsyncFahrschulnameValidationFormBloc>();
          return SingleChildScrollView(
            child: Form(
              key: _formKeyFirstPage,
              child: Column(children: [
                TextFieldBlocBuilder(
                  textFieldBloc: formBloc.fahrschulname,
                  suffixButton: SuffixButton.asyncValidating,
                  decoration: inputDecoration('Fahrschulname', null),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _ortController,
                  decoration: inputDecoration('PLZ', _errorMessageOrt),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly // Nur Zahlen zulassen
                  ],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie eine PLZ ein.';
                    }
                    if (_ort == null) {
                      return 'Bitte wählen Sie eine Stadt aus der Liste.';
                    }
                    return null;
                  },
                ),
                if (_results.isNotEmpty)
                  DropdownButton<ParseObject>(
                    isExpanded: true,
                    items: _results
                        .map((result) => DropdownMenuItem(
                              value: result,
                              child: Text(result.get<String>("Name")!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _ort = value;
                        _ortController.text = value!.get<String>("PLZ")!;
                      });
                    },
                    hint: Text("Wählen Sie eine Stadt"),
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _strasseController,
                  decoration: inputDecoration('Straße', null),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie eine Strasse ein.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _hausnummerController,
                  decoration: inputDecoration('Hausnummer', null),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie eine Hausnummer ein.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKeyFirstPage.currentState!.validate()) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
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
            ),
          );
        }));
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      child: Form(
        key: _formKeySecondPage,
        child: Column(
          children: [
            TextFormField(
              controller: _vornameController,
              decoration: inputDecoration('Vorname', null),
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
              decoration: inputDecoration('Nachname', null),
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
              decoration: inputDecoration('E-Mail', null),
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
              decoration: inputDecoration('Password', null),
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
              onPressed: () async {
                try {
                  if (_ort == null) throw ("88");
                  if (_fahrschulnameController == "Abc") throw (77);
                  //int a = 5;
                  await fahrschuleRegistration(
                      _fahrschulnameController.text,
                      _ort!,
                      _strasseController.text,
                      _hausnummerController.text,
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
                  if (mounted) {
                    int? indexflag = null;
                    if (e.toString() == "88") {
                      indexflag = 0;
                      setState(() {
                        _pageController.jumpToPage(indexflag!);
                        _errorMessageOrt = "Ort nicht gefunden";
                      });
                    }
                    if (indexflag == null) {
                      //In jede if wo der Fehler auf der zweiten Seite ist
                      indexflag = 1;
                    }

                    setState(() {
                      _pageController.jumpToPage(indexflag!);
                      _errorMessageOrt = "afaf";
                    }); //bis hier

                    if (e.toString() == "77") {
                      indexflag = 0;
                      setState(() {
                        _pageController.jumpToPage(indexflag!);
                        _errorMessageFahrschulname = "Fahrschulname fehler";
                      });
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF00BF6D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const StadiumBorder(),
              ),
              child: const Text('Registrieren'),
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
          MaterialPageRoute(builder: (context) => SignInScreen()),
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

  AsyncFahrschulnameValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [fahrschulname]);

    fahrschulname.addAsyncValidators(
      [checkIfFahrschuleExists],
    );
  }
}
