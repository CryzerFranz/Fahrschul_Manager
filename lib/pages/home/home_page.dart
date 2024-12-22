import 'package:fahrschul_manager/pages/home/homepage_fahrlehrer.dart';
import 'package:fahrschul_manager/pages/home/homepage_fahrschueler.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';
import '../../src/db_classes/user.dart';
import '../../widgets/navBar/navBar.dart';
import '../../widgets/navBar/navBarBloc.dart';
import '../../widgets/navBar/navBarEvent.dart';
import '../calendar_page/calendar_page.dart';
import '../fahrschueler_liste/fahrschueler_liste_page.dart';
import '../fahrschule_page.dart';
import '../profil_page/profil_page.dart';
import 'bloc/homePage_Bloc.dart';
import 'bloc/homePage_Event.dart';
import 'bloc/homePage_State.dart';

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
    FahrschuelerListePage(),
    CalendarPage(),
    HomePageFahrschueler(),
    FahrschulePage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    late List<Widget> assignedPages;
    if(Benutzer().isFahrlehrer!)
    {
      assignedPages = _pagesFahrlehrer;
    }else{
      assignedPages = _pagesFahrschueler;
    }
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




