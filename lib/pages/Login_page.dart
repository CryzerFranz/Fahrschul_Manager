import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/pages/Home_page.dart';
import 'package:fahrschul_manager/pages/Registration_page.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/decorations.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SigninScreenState createState() => _SigninScreenState();
}
  class _SigninScreenState extends State<SignInPage>{
  final _formKey = GlobalKey<FormState>();



  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

    @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 // String eMail = _emailController.text;
 // String password = _passwordController.text;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration:inputDecoration('E-Mail'),//TODO: Error Message erstellen
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            obscureText: true,
                            controller: _passwordController,
                            decoration: inputDecoration("Password"),//TODO: Error Message erstellen
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            bool isvalid=await Benutzer().login(_emailController.text.trim(),_passwordController.text.trim());
                            if(isvalid) {
                            // "luis@gmail.com", "ABC12345"
                              navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(builder: (context) => HomePage()),

                          );
                            }
                            else{
                              //setState
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF00BF6D),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Einloggen"),
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                        onPressed: () {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(builder: (context) => RegistrationPage()),
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
