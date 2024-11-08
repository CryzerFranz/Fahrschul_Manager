//import 'package:fahrschul_manager/src/authentication.dart';
import 'package:fahrschul_manager/doc/intern/Authentication.dart';
import 'package:fahrschul_manager/doc/intern/Dummys.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschule.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/src/db_classes/ort.dart';
import 'package:fahrschul_manager/src/db_classes/status.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/pages/Home_page.dart';
import 'package:fahrschul_manager/pages/Login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:calendar_view/calendar_view.dart';

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


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter - Parse Server',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
          future: Benutzer().hasUserLogged(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Scaffold(
                  body: Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator()),
                  ),
                );
              default:
                if (snapshot.hasData && snapshot.data!) {
                  return HomePage();
                } else {
                  return SignInScreen();
                }
            }
          }),
    );
  }
}
 
 
