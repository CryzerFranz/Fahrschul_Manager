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
  //ParseUser? currentUser = await ParseUser("test@gmail","12345678" , "test@gmail");
  //await currentUser.login();

 //final uquery = QueryBuilder<ParseUser>(ParseUser.forQuery())
 //     ..whereEqualTo('objectId', currentUser.objectId!);

  //  final ParseResponse response = await uquery.query();
  // ParseUser User = response.results!.first as ParseUser;



  //final QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('_Role'))
  // ..whereRelatedTo('users', '_User', currentUser.objectId);

  // final QueryBuilder<ParseObject> roleQuery = QueryBuilder<ParseObject>(ParseObject('_Role'))
  //     ..whereContainedIn('users', [User]);


  //final QueryBuilder<ParseObject> query =
  //        QueryBuilder<ParseObject>(ParseObject('_Role'))           
  //          ..whereContains('name', 'Fahrlehrer');
  // final ParseResponse roleResp = await roleQuery.query();
  // for (var role in roleResp.results!) {
  //       print('Role: ${(role as ParseObject).get<String>('name')}');
  //     }

  ParseUser? currentUser = await ParseUser("test@gmail","12345678" , "test@gmail");
  ParseUser? user = await ParseUser.currentUser() as ParseUser?;
  bool is342 = await Benutzer().initialize(user: currentUser);
  bool nowLooged = await Benutzer().login();
  

  //final user = ParseUser("pp@gmail.com", "12345678", "pp@gmail.com");
  //final ort = await getOrt("Stuttgart", "70619");
  //if(ort != null) {
  //  await fahrschuleRegistration("Luis die 2", ort, "Nuenberg", "A12312", "luis@gmail.com", "ABC12345", "vorname", "name");
  //}

    //final f = await getFahrschuleWithId("6oyNDpad2A");
    //await createFahrlehrer("rolen", "tester", "test@gmail", f!, "12345678");
    //await addFahrstunde(DateTime.utc(2024,12,12), DateTime.utc(2024,12,12,15,15,0), dummyRenault);
    //final status = await getStatus("Nicht zugewiesen");
    //print(status?.get('Typ'));
    
    //final user = await ParseUser.currentUser() as ParseUser?;
    //final islog = await logout(user!);
    //final f = await getFahrschuleWithId("6oyNDpad2A");
    //final test = await createFahrschueler("test", "login", "pp@gmail.com", "12345678", f!);
    
    runApp(MyApp());
  } else {
    runApp(ErrorApp());
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: Scaffold(body: Container(height: 700, child: WeekView())),
    );
    // return const Scaffold(body:
    // MonthView());
  }
}

class UserPage extends StatelessWidget {
  ParseUser? currentUser;

  @override
  Widget build(BuildContext context) {
    void doUserLogout() async {
      var response = await currentUser!.logout();
      if (response.success) {
        print("sucess LOGOUT");
      } else {
        print("ERROR LOGOUT");
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('User logged in - Current User'),
        ),
        body: FutureBuilder<ParseUser?>(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator()),
                  );
                default:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Text('Hello, ${snapshot.data!.username}')),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          height: 50,
                          child: ElevatedButton(
                            child: const Text('Logout'),
                            onPressed: () => doUserLogout(),
                          ),
                        ),
                      ],
                    ),
                  );
              }
            }));
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
          future: hasUserLogged(),
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
                  return UserPage(); // HOMEPAGE
                } else {
                  return MyWidget(); // LOGIN-PAGE
                }
            }
          }),
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

class ErrorApp extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: 'Internal Error',
       theme: ThemeData(
         primarySwatch: Colors.red,
         visualDensity: VisualDensity.adaptivePlatformDensity,
       ),
       home:const Scaffold(body: Center(child: Text("!Internal Error!", style: TextStyle(color: Colors.red)))),
     );
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
          future: hasUserLogged(),
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
 
 
