
import 'package:fahrschul_manager/widgets/navBar.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hallo'),
      ),
      bottomNavigationBar: CustomNavBar());
  }
}
