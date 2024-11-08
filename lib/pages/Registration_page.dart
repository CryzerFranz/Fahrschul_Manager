import 'package:fahrschul_manager/pages/Login_page.dart';
import 'package:fahrschul_manager/widgets/decorations.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Form field controllers
  final TextEditingController _fahrschulnameController = TextEditingController();
  final TextEditingController _ortController = TextEditingController();
  final TextEditingController _strasseController = TextEditingController();
  final TextEditingController _vornameController = TextEditingController();
  final TextEditingController _nachnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int currentPage = 0; // Variable to track the current page

  @override
  void dispose() {
    _fahrschulnameController.dispose();
    _ortController.dispose();
    _strasseController.dispose();
    _vornameController.dispose();
    _nachnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            currentPage = page;
                          });
                        },
                        children: [
                          _buildFirstPage(),
                          _buildSecondPage(),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    _buildPageIndicator(), // Add the page indicator here
                    SizedBox(height: 16.0),
                    _buildLoginRedirect(context),
                    SizedBox(height: 16.0),
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _fahrschulnameController,
              decoration: inputDecoration('Fahrschulname'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _ortController,
              decoration: inputDecoration('Ort'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _strasseController,
              decoration: inputDecoration('Straße'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: _vornameController,
              decoration: inputDecoration('Vorname'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _nachnameController,
              decoration: inputDecoration('Nachname'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: inputDecoration('E-Mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: inputDecoration('Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _handleRegistration();
              },
              child: Text('Registrieren'),
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
          duration: Duration(milliseconds: 300),
        // Add horizontal spacing between indicators
          margin: EdgeInsets.symmetric(horizontal: 4.0),
        // Make the current page indicator slightly larger
          width: currentPage == index ? 12.0 : 8.0,
          height: currentPage == index ? 12.0 : 8.0,
          decoration: BoxDecoration(
          // Highlight current page indicator with blue, others grey
            color: currentPage == index ? Colors.blue : Colors.grey,
          // Make indicators circular
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  void _handleRegistration() {
    final registrationData = {
      'fahrschulname': _fahrschulnameController.text,
      'ort': _ortController.text,
      'strasse': _strasseController.text,
      'vorname': _vornameController.text,
      'nachname': _nachnameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    print(registrationData);
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
        TextSpan(
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
