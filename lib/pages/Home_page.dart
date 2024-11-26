import 'package:fahrschul_manager/pages/authentication/login_page.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/navBar.dart';
import 'package:fahrschul_manager/widgets/navBar/navBar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true -> damit bottomnavbar transparent sein kann
      extendBody: true,
        body: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100, left: 20, right: 20 ),
              child: Column(
                children: [
                  Custom3DCard(
                    title: 'Test 3D Card mit widget',
                    widget: CustomNavBar(),
                  ),
                  const SizedBox(height: 30),
                  Custom3DCard(title: "Meine Fahrschüler", widget: Text("52")),
                 
                ],
              ),
            ),
        bottomNavigationBar: CustomNavBar());
  }
}

