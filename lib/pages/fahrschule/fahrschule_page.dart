import 'package:fahrschul_manager/pages/fuhrpark_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_bloc.dart';
import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_event.dart';
import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_state.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';

class FahrschulePage extends StatelessWidget {
  const FahrschulePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FahrschulePageBloc>().add(FetchData());

    return BlocBuilder<FahrschulePageBloc, FahrschulePageState>(
      builder: (context, state) {
        if (state is DataLoading) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (state is DataLoaded) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 80.0, bottom: 16, left: 16, right: 16),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Benutzer().fahrschule!.get<String>("Name")!,
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Custom3DCard(
                          title: "Die Fahrlehrer",
                          colors: const [mainColor, mainColor, tabBarMainColorShade100],
                          widget: LayoutBuilder(
                            builder: (context, constraints) {
                              final pageController = PageController(); // Für den Page indicator
                              return Column(
                                children: [
                                  Container(
                                    height: 120,
                                    color: Colors.transparent,
                                    child: PageView.builder(
                                      controller: pageController,       //controller zuweisen
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.fahrlehrer.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: constraints.maxWidth,
                                          alignment: Alignment.center,
                                          child: fahrlehrerView(state.fahrlehrer[index]),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SmoothPageIndicator(          //verbunden mit dem PageView durch den controller
                                    controller: pageController,
                                    count: state.fahrlehrer.length,
                                    effect: const WormEffect(
                                      dotHeight: 12,
                                      dotWidth: 12,
                                      activeDotColor: mainColorComplementarySecond,
                                      dotColor: mainColorComplementaryFirstShade100,
                                    ),
                                  ),
                                  

                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Custom3DCard(
                          title: "Die Standorte",
                          colors: const [mainColor, mainColor, tabBarMainColorShade100],
                          widget: LayoutBuilder(
                            builder: (context, constraints) {
                              final pageController = PageController(); // Für den Page indicator
                              return Column(
                                children: [
                                  Container(
                                    height: 50,
                                    color: Colors.transparent,
                                    child: PageView.builder(
                                      controller: pageController,       //controller zuweisen
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.locations.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: constraints.maxWidth,
                                          alignment: Alignment.center,
                                          child: locationsView(state.locations[index]),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SmoothPageIndicator(          //verbunden mit dem PageView durch den controller
                                    controller: pageController,
                                    count: state.locations.length,
                                    effect: const WormEffect(
                                      dotHeight: 12,
                                      dotWidth: 12,
                                      activeDotColor: mainColorComplementarySecond,
                                      dotColor: mainColorComplementaryFirstShade100,
                                    ),
                                  ),
                                  

                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Fuhrpark button
              Positioned(
                top: 50,
                right: 20,
                child: FloatingActionButton(
               shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FuhrparkPage(),
              ),
            );
                  },
                  backgroundColor: mainColor,
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 37
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text("Network error"));
        }
      },
    );
  }

  Widget locationsView(ParseObject location)
  {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${location.get<String>("Strasse")!} - ${location.get<String>("Hausnummer")!}", style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
          const SizedBox(height: 5),
          Text("${location.get<ParseObject>("Ort")!.get<String>("PLZ")}, ${location.get<ParseObject>("Ort")!.get<String>("Name")}", style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
        ],
      )
    );
  }

  Widget fahrlehrerView(ParseObject fahrlehrer) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.person,
              size: 30,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${fahrlehrer.get<String>("Name")}, ${fahrlehrer.get<String>("Vorname")}",
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
