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
              tabs: [
                SegmentTab(
                  label: 'AKTIV',
                  color: mainColorShade300,
                  backgroundColor: mainColorShade100,
                ),
                SegmentTab(
                  label: 'PASSIV',
                  backgroundColor: Colors.orange.shade100,
                  color: Colors.orange.shade300,
                ),
                SegmentTab(
                  label: 'NEU',
                  backgroundColor: Colors.red.shade100,
                  color: Colors.red.shade300,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 70),
            child: TabBarView(
              physics: BouncingScrollPhysics(),
              children: [
                FahrschuelerListContent(state: "Aktiv"),
                FahrschuelerListContent(state: "Passiv"),
                FahrschuelerListContent(state: "Nicht zugewiesen"),
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
  });

  final String state;
  @override
  Widget build(BuildContext context) {
    context.read<FahrschuelerListBloc>().add(FetchFahrschuelerListEvent(state));

    return BlocBuilder<FahrschuelerListBloc, FahrschuelerListState>(
      builder: (context, state) {
        if (state is DataLoading) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (state is DataLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.data.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Custom3DCard(
                    title: "${state.data[index].get<String>("Name")!}, "
                        "${state.data[index].get<String>("Vorname")!}",
                    widget: const Text("Test"),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          );
        } else if (state is DataError) {
          return Center(child: Text("Error: ${state.message}"));
        } else {
          return Center(child: Text("No data"));
        }
      },
    );
  }
}
