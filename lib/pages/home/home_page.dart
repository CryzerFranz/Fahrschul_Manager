import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';
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
    context.read<HomePageBloc>().add(FetchData());
    return BlocBuilder<HomePageBloc, HomePageState>(builder: (context, state) {
      if (state is DataLoading) {
        return loadingScreen(height_: 150, width_: 150);
      } else if (state is DataLoaded) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              AspectRatio(
                aspectRatio: 1, // Ensures a square container
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 5,
                    centerSpaceRadius: 30,
                    sections: showingSections(state),
                  ),
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.linear,
                ),
              ),
            ],
          ),
        );
      }
      return Text("Error");
    });
  }

  List<PieChartSectionData> showingSections(DataLoaded state) {
    return List.generate(2, (i) {
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: tabBarMainColorShade300,
            value: state.percentActive,
            title: state.activeCount.toString(),
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
            value: state.percentPassive,
            title: state.passiveCount.toString(),
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
