import 'package:fahrschul_manager/pages/authentication/login_page.dart';
import 'package:fahrschul_manager/pages/calendar_page.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/fahrschueler_liste_page.dart';
import 'package:fahrschul_manager/pages/fahrschule_page.dart';
import 'package:fahrschul_manager/pages/profil_page.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/navBar/navBar.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarBloc.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Widget> _pages =  const [
    FahrschuelerListePage(),
    CalendarPage(),
    HomePageBody(),
    FahrschulePage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      extendBody: true,
      body: BlocBuilder<NavBarBloc, NavBarState>(
        builder: (context, state) {
          return _pages[state.selectedIndex];
        },
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}
class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            );
  }
}

