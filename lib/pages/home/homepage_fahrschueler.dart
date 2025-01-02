import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrstunde.dart';
import 'package:fahrschul_manager/pages/home/cubit/homepage_fahrschueler_cubit.dart';
import 'package:fahrschul_manager/pages/home/widgets.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschueler.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePageFahrschueler extends StatelessWidget {
  const HomePageFahrschueler({super.key});

  @override
  Widget build(BuildContext context) {
    late HomepageFahrschuelerCubit cubit;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 16, right: 16),
            child: Custom3DCard(
                title: "Fahrlehrer", widget: displayFahrlehrer(context)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 16, right: 16),
            child: Custom3DCard(
                title: "Deine Fahrstunden",
                widget: displayFahrstunden(context)),
          ),
          const SizedBox(height: 12),
          // BlocProvider(
          // create: (context) {
          // cubit = HomepageFahrschuelerCubit();
          // //cubit.fetchAppointmentsToSignIn();
          // return cubit;
          // },
          if(Benutzer().dbUser!.get<ParseObject>("Status")!.get<String>("Typ") == stateActive && Benutzer().dbUser!.get<ParseObject>("Fahrlehrer") != null) ...[
          StreamBuilder<List<ParseObject>>(
              stream: fetchFahrstundenFromFahrlehrerStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingScreen();
                } else if (snapshot.hasError) {
                  return Custom3DCard(
                      widget: const Center(child: Text("Error")));
                }
                context
                    .read<HomepageFahrschuelerCubit>()
                    .transfromAppointsments(snapshot.data!);
                return BlocBuilder<HomepageFahrschuelerCubit,
                    HomepageFahrschuelerCubitState>(builder: (context, state) {
                  if (state is CubitLoading) {
                    return loadingScreen();
                  } else if (state is CubitError) {
                    return Custom3DCard(widget: const Center(child: Text("Error")));
                  }
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 5.0, left: 16, right: 16),
                    child: Custom3DCard(
                      title: "Mögliche Termine",
                      colors: const [
                        mainColor,
                        mainColor,
                        tabBarMainColorShade100
                      ],
                      widget: LayoutBuilder(
                        builder: (context, constraints) {
                          final pageController = PageController();
                          if ((state as CubitLoaded).appointments.isEmpty) {
                            return const Center(
                              child: Text(
                                "Keine Fahrstunde sind aktuell vom Fahrlehrer freigestellt!",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                Container(
                                  height: 180,
                                  color: Colors.transparent,
                                  child: PageView.builder(
                                    controller: pageController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.appointments.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          width: constraints.maxWidth,
                                          alignment: Alignment.center,
                                          child: nextFahrstundeContent(
                                              cubit: context.read<
                                                  HomepageFahrschuelerCubit>(),
                                              next: state.appointments[index],
                                              currentIndex: index,
                                              length:
                                                  state.appointments.length));
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SmoothPageIndicator(
                                  controller: pageController,
                                  count: state.appointments.length,
                                  effect: const WormEffect(
                                    dotHeight: 12,
                                    dotWidth: 12,
                                    activeDotColor:
                                        mainColorComplementarySecond,
                                    dotColor:
                                        mainColorComplementaryFirstShade100,
                                  ),
                                )
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  );
                });
              }),]
        ],
      ),
    );
  }

  Widget displayFahrstunden(BuildContext context) {
    return Row(
      children: [
        Text(
          Benutzer().dbUser!.get("Gesamtfahrstunden")!.toString(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Text(
          "Fahrstunden vollbracht",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget displayFahrlehrer(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            hasFahrlehrer(Benutzer().dbUser!)
                ? Icons.person
                : Icons.question_mark,
            size: 30,
            color: mainColor,
          ),
        ),
        const SizedBox(width: 20),
        hasFahrlehrer(Benutzer().dbUser!)
            ? Text(
                "${Benutzer().dbUser!.get<ParseObject>("Fahrlehrer")!.get<String>("Name")}, ${Benutzer().dbUser!.get<ParseObject>("Fahrlehrer")!.get<String>("Vorname")}",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
              )
            : Text(
                "Kein Fahrlehrer zugewiesen",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
              ),
      ],
    );
  }
}
