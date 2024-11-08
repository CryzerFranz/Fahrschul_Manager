import 'package:flutter/material.dart';

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
                 const Center(
                   child: Text('Flutter on Back4App',
                       style:
                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
                 const SizedBox(
                   height: 16,
                 ),
                 const Center(
                   child: Text('User registration',
                      style: TextStyle(fontSize: 16)),
                 ),
                 const SizedBox(
                   height: 16,
                 ),
                 TextField(
                   controller: controllerUsername,
                   keyboardType: TextInputType.text,
                   textCapitalization: TextCapitalization.none,
                   autocorrect: false,
                   decoration: const InputDecoration(
                       border: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.black)),
                       labelText: 'Username'),
                 ),
                 const SizedBox(
                   height: 8,
                 ),
                 TextField(
                   controller: controllerEmail,
                   keyboardType: TextInputType.emailAddress,
                   textCapitalization: TextCapitalization.none,
                   autocorrect: false,
                   decoration: const InputDecoration(
                       border: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.black)),
                       labelText: 'E-mail'),
                 ),
                 const SizedBox(
                   height: 8,
                 ),
                 TextField(
                   controller: controllerPassword,
                   obscureText: true,
                   keyboardType: TextInputType.text,
                   textCapitalization: TextCapitalization.none,
                   autocorrect: false,
                   decoration: const InputDecoration(
                       border: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.black)),
                       labelText: 'Password'),
                 ),
                 const SizedBox(
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
             ElevatedButton(
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
             ElevatedButton(
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