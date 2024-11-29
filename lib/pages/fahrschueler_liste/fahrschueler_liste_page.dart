import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_bloc.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_event.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_state.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class FahrschuelerListePage extends StatelessWidget {
  const FahrschuelerListePage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedTabControl(
              tabTextColor: Colors.black,
              selectedTabTextColor: Colors.white,
              indicatorPadding: const EdgeInsets.all(4),
              squeezeIntensity: 2,
              tabPadding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: Theme.of(context).textTheme.bodyLarge,
              selectedTextStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              tabs: const [
                SegmentTab(
                  label: 'AKTIV',
                  color: tabBarMainColorShade300,
                  backgroundColor: tabBarMainColorShade100,
                ),
                SegmentTab(
                  label: 'PASSIV',
                  backgroundColor: tabBarOrangeShade100,
                  color: tabBarOrangeShade300,
                ),
                SegmentTab(
                  label: 'NEU',
                  backgroundColor: tabBarRedShade100,
                  color: tabBarRedShade300,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 70),
            child: TabBarView(
              physics: BouncingScrollPhysics(),
              children: [
                FahrschuelerListContent(state: "Aktiv", colors: [tabBarMainColorShade300, tabBarMainColorShade300, tabBarMainColorShade100]),
                FahrschuelerListContent(state: "Passiv", colors: [tabBarOrangeShade300, tabBarOrangeShade300, tabBarOrangeShade100],),
                FahrschuelerListContent(state: "Nicht zugewiesen", colors: [tabBarRedShade300, tabBarRedShade300, tabBarRedShade100]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FahrschuelerListContent extends StatelessWidget {
  const FahrschuelerListContent({
    super.key,
    required this.state,
    this.colors = const [mainColor, mainColor, mainColorComplementaryFirst],
  });

  final String state;
  final List<Color> colors;
  @override
  Widget build(BuildContext context) {
    context.read<FahrschuelerListBloc>().add(FetchFahrschuelerListEvent(state));

    return BlocBuilder<FahrschuelerListBloc, FahrschuelerListState>(
      builder: (context, blocState) {
        if (blocState is DataLoading) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (blocState is DataLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: blocState.data.length,
            itemBuilder: (BuildContext context, int index) {
              if(state != "Nicht zugewiesen") {
                return displayDataForAssigned(blocState, index);
              }
              else{
                return displayDataForUnassigned(context ,blocState, index);

              }
            },
          );
        } else if (blocState is DataError) {
          return Center(child: Text("Error: ${blocState.message}"));
        } else {
          return Center(child: Text("No data"));
        }
      },
    );
  }

  Widget displayDataForAssigned(DataLoaded state, int index) {
    return Column(
              children: [
                Custom3DCard(
                  title: "${state.data[index].get<String>("Name")!}, "
                      "${state.data[index].get<String>("Vorname")!}",
                  widget: const Text("Test"),
                  colors: colors,
                ),
                const SizedBox(height: 10),
              ],
            );
  }

  Widget displayDataForUnassigned(BuildContext context, state, int index) {
    return Column(
              children: [
                Row(
                  children: [
                    Custom3DCard(
                      title: "${state.data[index].get<String>("Name")!},"
                          "${state.data[index].get<String>("Vorname")!}",
                      widget: const Text("Test"),
                      colors: colors,
                      width: 0.7,
                    ),
                    SizedBox(width: 10),
                    Custom3DCard(
                      widget: IconButton(onPressed: (){}, icon: Icon(Icons.add)),
                      colors: [colors.last, colors.first],
                      width: 0.17,
          
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            );
  }
}
