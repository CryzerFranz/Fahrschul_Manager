import 'package:calendar_view/calendar_view.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/navBar/navBar.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarBloc.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CalendarEventData>>(
      stream: getUserFahrstundenStream(), // Periodically fetch events
      builder: (BuildContext context,
          AsyncSnapshot<List<CalendarEventData>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          final events = snapshot.data!;
          return CalendarControllerProvider(
            controller: EventController()..addAll(events),
            child: WeekView(
              weekDays: [WeekDays.monday, WeekDays.tuesday, WeekDays.wednesday, WeekDays.thursday, WeekDays.friday, WeekDays.saturday],
              onEventTap: (events, date) {
               navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                  builder: (context) => CalendarEventPage()),
                            );
              },
            ),
          );
        }
      },
    );
  }
}

class CalendarEventPage extends StatelessWidget {
  const CalendarEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,),
      body: BlocBuilder<NavBarBloc, NavBarState>(
        builder: (context, state) {
          if(state is NavBarItemTapped)
            return pages[state.selectedIndex];
          return Center(child: Text("Hallo"));
        },
      ));
  }
}
