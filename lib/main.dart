import 'package:fahrschul_manager/pages/authentication/first_login/AsyncPasswordResetValidationFormBloc.dart';
import 'package:fahrschul_manager/pages/authentication/first_login/bloc/password_change_bloc.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_bloc.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/AsyncPersonDataValidationFormBloc.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_bloc.dart';
import 'package:fahrschul_manager/pages/fahrzeug_add/bloc/fahrzeug_add_bloc.dart';
import 'package:fahrschul_manager/pages/fuhrpark/bloc/fuhrpark_bloc.dart';
import 'package:fahrschul_manager/pages/home/Home_page.dart';
import 'package:fahrschul_manager/pages/home/bloc/homePage_Bloc.dart';
import 'package:fahrschul_manager/pages/profil_page/bloc/profil_page_bloc.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/pages/authentication/Login_page.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncLoginValidationFormBloc.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncRegistrationValidationFormBloc.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncFahrzeugAddValidationFormBloc.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'pages/fahrschule/bloc/fahrschule_page_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyParseServerUrl = 'https://parseapi.back4app.com';

  final String? _clientKey = await getClientID();
  final String? _applicationID = await getApplicationID();

  if (_applicationID != null && _clientKey != null) {
    await Parse().initialize(
      _applicationID,
      keyParseServerUrl,
      clientKey: _clientKey,
      debug: true,
    );
    Benutzer().initialize();
    //await Benutzer().login("cp@gmail.com", "Admin12345.");

    runApp(MyApp());
  } else {
    runApp(ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'Internal Error',
          theme: ThemeData(
            primarySwatch: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const Scaffold(
              body: Center(
                  child: Text("!Internal Error!",
                      style: TextStyle(color: Colors.red)))),
        );
  }
}

Future<String?> getApplicationID() async {
  const platform = MethodChannel('com.example.fahrschul_manager/keys');
  try {
    final String applicationID = await platform.invokeMethod(
        'getGradleApplicationIDValue'); // Match Kotlin method name
    return applicationID;
  } on PlatformException catch (e) {
    return null;
  }
}

Future<String?> getClientID() async {
  const platform = MethodChannel('com.example.fahrschul_manager/keys');
  try {
    final String clientID = await platform
        .invokeMethod('getGradleClientIDValue'); // Match Kotlin method name
    return clientID;
  } on PlatformException catch (e) {
    return null;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _userLoggedFuture;

  @override
  void initState() {
    super.initState();
    _userLoggedFuture = Benutzer().hasUserLogged();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavBarBloc()),
        BlocProvider(create: (context) => AsyncRegistrationValidationFormBloc()),
        BlocProvider(create: (context) => AsyncLoginValidationFormBloc()),
        BlocProvider(create: (context) => FahrschuelerListBloc()),
        BlocProvider(create: (context) => PasswordChangeBloc()),
        BlocProvider(create: (context) => ProfilPageBloc()),
        BlocProvider(create: (context) => CalendarEventBloc()),
        BlocProvider(create: (context) => HomePageBloc()),
        BlocProvider(create: (context) => AsyncFahrzeugAddValidationFormBloc()),
        BlocProvider(create: (context) => AsyncPersonDataValidationFormBloc()),
        BlocProvider(create: (context) => AsyncPasswordResetValidationFormBloc()),
        BlocProvider(create: (context) => FahrzeugAddBloc()),
<<<<<<< Updated upstream
        BlocProvider(create: (context) => FahrschulePageBloc()),
=======

>>>>>>> Stashed changes
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter - Parse Server',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder<bool>(
          future: _userLoggedFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return ScaffoldLoadingScreen();
              default:
                if (snapshot.hasData && snapshot.data!) {
                  return HomePage();
                } else {
                  return SignInPage();
                }
            }
          },
        ),
      ),
    );
  }
}



