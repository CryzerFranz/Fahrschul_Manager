import 'package:fahrschul_manager/pages/fahrschule/fahrschule_page.dart';
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
import '../profil_page/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NavBarBloc navBarBloc;
  late final bool isFahrlehrer;
  late final List<Widget> assignedPages;

  @override
  void initState() {
    super.initState();

    navBarBloc = context.read<NavBarBloc>();

    isFahrlehrer = Benutzer().isFahrlehrer ?? false;

    // Initialize role in NavBarBloc
    navBarBloc.add(NavBarRoleInitialized(isFahrlehrer));

    // Assign pages based on role
    assignedPages = isFahrlehrer
        ? const [
            FahrschuelerListePage(),
            CalendarPage(),
            HomePageFahrlehrer(),
            FahrschulePage(),
            ProfilPage(),
          ]
        : const [
            CalendarPage(),
            HomePageFahrschueler(),
            FahrschulePage(),
            ProfilPage(),
          ];

    // Set initial selected page
    navBarBloc.add(
      isFahrlehrer ? const NavBarItemTapped(2) : const NavBarItemTapped(1),
    );
  }

  @override
  void dispose() {
    navBarBloc.add(NavBarItemTapped(0));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
