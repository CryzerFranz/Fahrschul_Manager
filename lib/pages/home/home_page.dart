import 'package:fahrschul_manager/pages/home/homepage_fahrlehrer.dart';
import 'package:fahrschul_manager/pages/home/homepage_fahrschueler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../src/db_classes/user.dart';
import '../../widgets/navBar/navBar.dart';
import '../../widgets/navBar/navBarBloc.dart';
import '../../widgets/navBar/navBarEvent.dart';
import '../calendar_page/calendar_page.dart';
import '../fahrschueler_liste/fahrschueler_liste_page.dart';
import '../fahrschule_page.dart';
import '../profil_page/profil_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Widget> _pagesFahrlehrer = const [
    FahrschuelerListePage(),
    CalendarPage(),
    HomePageFahrlehrer(),
    FahrschulePage(),
    ProfilPage(),
  ];

  final List<Widget> _pagesFahrschueler = const [
    CalendarPage(),
    HomePageFahrschueler(),
    FahrschulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isFahrlehrer = Benutzer().isFahrlehrer ?? false;

    // Initialize role in NavBarBloc
    context.read<NavBarBloc>().add(NavBarRoleInitialized(isFahrlehrer));

    // Select pages based on role
    final assignedPages = isFahrlehrer ? _pagesFahrlehrer : _pagesFahrschueler;

    return Scaffold(
      extendBody: true,
      body: BlocBuilder<NavBarBloc, NavBarState>(
        builder: (context, state) {
          return assignedPages[state.selectedIndex];
        },
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}



