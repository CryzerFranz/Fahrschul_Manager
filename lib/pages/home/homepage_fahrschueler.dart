import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/home/cubit/homepage_fahrschueler_cubit.dart';
import 'package:fahrschul_manager/pages/home/widgets.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../src/db_classes/fahrstunde.dart';

class HomePageFahrschueler extends StatelessWidget {
  const HomePageFahrschueler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 80),
          _buildFahrlehrerCard(context),
          const SizedBox(height: 12),
          _buildFahrstundenCard(context),
          const SizedBox(height: 12),
          if (_isUserActiveAndHasFahrlehrer()) _buildAppointmentsStream(context),
        ],
      ),
    );
  }

  bool _isUserActiveAndHasFahrlehrer() {
    final user = Benutzer().dbUser;
    return user != null &&
        user.get<ParseObject>("Status")?.get<String>("Typ") == stateActive &&
        user.get<ParseObject>("Fahrlehrer") != null;
  }

  Widget _buildFahrlehrerCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Custom3DCard(
        title: "Fahrlehrer",
        widget: _displayFahrlehrer(context),
      ),
    );
  }

  Widget _buildFahrstundenCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Custom3DCard(
        title: "Deine Fahrstunden",
        widget: _displayFahrstunden(context),
      ),
    );
  }

  Widget _buildAppointmentsStream(BuildContext context) {
    return StreamBuilder<List<ParseObject>>(
      stream: fetchFahrstundenFromFahrlehrerStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingScreen();
        } else if (snapshot.hasError) {
          return _buildErrorCard("Fehler beim Laden der Termine");
        } else if (snapshot.hasData) {
          context.read<HomepageFahrschuelerCubit>().transfromAppointsments(snapshot.data!);
          return BlocBuilder<HomepageFahrschuelerCubit, HomepageFahrschuelerCubitState>(
            builder: (context, state) {
              if (state is CubitLoading) {
                return loadingScreen();
              } else if (state is CubitError) {
                return _buildErrorCard("Fehler beim Verarbeiten der Termine");
              } else if (state is CubitLoaded && state.appointments.isEmpty) {
                return _buildEmptyAppointmentsCard();
              } else if (state is CubitLoaded) {
                return _buildAppointmentsCard(context, state);
              }
              return const SizedBox.shrink();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorCard(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Custom3DCard(
        widget: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Custom3DCard(
        title: "Mögliche Termine",
        widget: const Center(
          child: Text(
            "Keine Fahrstunden sind aktuell vom Fahrlehrer freigestellt!",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsCard(BuildContext context, CubitLoaded state) {
    final pageController = PageController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Custom3DCard(
        title: "Mögliche Termine",
        colors: const [mainColor, mainColor, tabBarMainColorShade100],
        widget: Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: pageController,
                itemCount: state.appointments.length,
                itemBuilder: (context, index) {
                  return nextFahrstundeContent(
                    cubit: context.read<HomepageFahrschuelerCubit>(),
                    next: state.appointments[index],
                    currentIndex: index,
                    length: state.appointments.length,
                  );
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
                activeDotColor: mainColorComplementarySecond,
                dotColor: mainColorComplementaryFirstShade100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayFahrstunden(BuildContext context) {
    final totalFahrstunden = Benutzer().dbUser?.get("Gesamtfahrstunden") ?? 0;
    return Row(
      children: [
        Text(
          totalFahrstunden.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(width: 10),
        Text(
          "Fahrstunden vollbracht",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ],
    );
  }

  Widget _displayFahrlehrer(BuildContext context) {
    final hasFahrlehrer = Benutzer().dbUser?.get<ParseObject>("Fahrlehrer") != null;
    final fahrlehrerName = hasFahrlehrer
        ? "${Benutzer().dbUser!.get<ParseObject>("Fahrlehrer")!.get<String>("Name")}, ${Benutzer().dbUser!.get<ParseObject>("Fahrlehrer")!.get<String>("Vorname")}"
        : "Kein Fahrlehrer zugewiesen";

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
            hasFahrlehrer ? Icons.person : Icons.question_mark,
            size: 30,
            color: mainColor,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          fahrlehrerName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ],
    );
  }
}
