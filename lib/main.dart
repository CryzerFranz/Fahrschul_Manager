//import 'package:fahrschul_manager/src/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyParseServerUrl = 'https://parseapi.back4app.com';

  final String? _clientKey = await getClientID();
  final String? _applicationID = await getApplicationID();

  if(_applicationID != null && _clientKey != null)
  {
    await Parse().initialize(
      _applicationID, 
      keyParseServerUrl,
      clientKey: _clientKey, 
      debug: true
    );
    runApp(MyApp());
  }
  else{
    runApp(ErrorApp());
  }

}


Future<String?> getApplicationID() async {
  const platform = MethodChannel('com.example.fahrschul_manager/keys');
  try {
    final String applicationID = await platform.invokeMethod('getGradleApplicationIDValue'); // Match Kotlin method name
    return applicationID;
  } on PlatformException catch (e) {
    return null; 
  }
}

Future<String?> getClientID() async {
  const platform = MethodChannel('com.example.fahrschul_manager/keys');
  try {
    final String clientID = await platform.invokeMethod('getGradleClientIDValue'); // Match Kotlin method name
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
       title: 'Flutter SignUp',
       theme: ThemeData(
         primarySwatch: Colors.blue,
         visualDensity: VisualDensity.adaptivePlatformDensity,
       ),
       home: HomePage(),
     );
   }
 }
 
 class HomePage extends StatefulWidget {
   @override
   _HomePageState createState() => _HomePageState();
 }
 
 class _HomePageState extends State<HomePage> {
   final controllerUsername = TextEditingController();
   final controllerPassword = TextEditingController();
   final controllerEmail = TextEditingController();
 
   @override
   Widget build(BuildContext context) {
     return Scaffold(
         appBar: AppBar(
           title: const Text('Flutter SignUp'),
         ),
         body: Center(
           child: SingleChildScrollView(
             padding: const EdgeInsets.all(8),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Container(
                   height: 200,
                   child: Image.network(
                       'http://blog.back4app.com/wp-content/uploads/2017/11/logo-b4a-1-768x175-1.png'),
                 ),
                 Center(
                   child: const Text('Flutter on Back4App',
                       style:
                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
                 SizedBox(
                   height: 16,
                 ),
                 Center(
                   child: const Text('User registration',
                      style: TextStyle(fontSize: 16)),
                 ),
                 SizedBox(
                   height: 16,
                 ),
                 TextField(
                   controller: controllerUsername,
                   keyboardType: TextInputType.text,
                   textCapitalization: TextCapitalization.none,
                   autocorrect: false,
                   decoration: InputDecoration(
                       border: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.black)),
                       labelText: 'Username'),
                 ),
                 SizedBox(
                   height: 8,
                 ),
                 TextField(
                   controller: controllerEmail,
                   keyboardType: TextInputType.emailAddress,
                   textCapitalization: TextCapitalization.none,
                   autocorrect: false,
                   decoration: InputDecoration(
                       border: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.black)),
                       labelText: 'E-mail'),
                 ),
                 SizedBox(
                   height: 8,
                 ),
                 TextField(
                   controller: controllerPassword,
                   obscureText: true,
                   keyboardType: TextInputType.text,
                   textCapitalization: TextCapitalization.none,
                   autocorrect: false,
                   decoration: InputDecoration(
                       border: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.black)),
                       labelText: 'Password'),
                 ),
                 SizedBox(
                   height: 8,
                 ),
                 Container(
                   height: 50,
                   child: TextButton(
                     child: const Text('Sign Up'),
                     onPressed: () => doUserRegistration(),
                   ),
                 )
               ],
             ),
           ),
         ));
   }
 
   void showSuccess() {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text("Success!"),
           content: const Text("User was successfully created!"),
           actions: <Widget>[
             new ElevatedButton(
               child: const Text("OK"),
               onPressed: () {
                 Navigator.of(context).pop();
               },
             ),
           ],
         );
       },
     );
   }
 
   void showError(String errorMessage) {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text("Error!"),
           content: Text(errorMessage),
           actions: <Widget>[
             new ElevatedButton(
               child: const Text("OK"),
               onPressed: () {
                 Navigator.of(context).pop();
               },
             ),
           ],
         );
       },
     );
   }
 
   void doUserRegistration() async {
 		//Sigup code here
   }
 }