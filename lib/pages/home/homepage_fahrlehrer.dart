import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/home/bloc/homePage_Bloc.dart';
import 'package:fahrschul_manager/pages/home/bloc/homePage_Event.dart';
import 'package:fahrschul_manager/pages/home/bloc/homePage_State.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class HomePageFahrlehrer extends StatelessWidget {
  const HomePageFahrlehrer({super.key});

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
              
              Custom3DCard(
                colors: [mainColor, mainColor, tabBarMainColorShade100],
                title: "Deine Fahrschüler",
                widget:AspectRatio(
  aspectRatio: 1.7, // Ensures a square container
  child: Container(
    decoration: BoxDecoration(
      color: Colors.transparent, // Background color of the container
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Shadow color
          spreadRadius: 0, // How much the shadow spreads
          blurRadius: 10, // How soft the shadow is
          offset: Offset(0, 0), // Offset of the shadow (x, y)
        ),
      ],
      shape: BoxShape.circle, // Makes the shadow circular
    ),
    child: PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 10,
        centerSpaceRadius: 30,
        sections: showingSections(state),
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear,
    ),
  ),
),
              ),
              SizedBox(height: 30),
              Custom3DCard(title: "Dein nächster Termin" ,widget: nextFahrstundeContent(state.nextFahrstunde), colors: [mainColor, mainColor, tabBarMainColorShade100])
            ],
          ),
        );
      }
      return Text("Error");
    });
  }

  Widget nextFahrstundeContent(Fahrstunde? next) {
  if (next == null) {
    return const Center(
      child: Text(
        "Keine Fahrstunde steht als nächstes mehr an!",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.user,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fahrschüler:",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      next.getFahrschueler(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.car,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fahrzeug:",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      next.getFahrzeug(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const Icon(
            FontAwesomeIcons.clock,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            "Start: ${next.dateToString()}",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          const Icon(
            FontAwesomeIcons.clock,
            size: 18,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            "Ende: ${next.endDateToString()}",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    ],
  );
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
