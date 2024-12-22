import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/calendar_page/calendar_page.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/fahrschueler_liste_page.dart';
import 'package:fahrschul_manager/pages/fahrschule_page.dart';
import 'package:fahrschul_manager/pages/profil_page/profil_page.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/navBar/navBar.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarBloc.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarEvent.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Widget> _pages = const [
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          Custom3DCard(title: "Meine Fahrschüler", widget: Text("52")),
          const SizedBox(height: 30), // Add spacing between widgets
          AspectRatio(
            aspectRatio: 1, // Ensures a square container
            child: PieChart(
              PieChartData(
                borderData: FlBorderData(show: false),
                sectionsSpace: 5,
                centerSpaceRadius: 30,
                sections: showingSections(),
              ),
              duration: const Duration(milliseconds: 150),
              curve: Curves.linear,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: tabBarMainColorShade300,
            value: 40,
            title: '40%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: tabBarOrangeShade300,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        
        default:
          throw Error();
      }
    });
  }
}
