import 'package:calendar_view/calendar_view.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/main.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/widgets/calendar_view_customization.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/navBar/navBar.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarBloc.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarEvent.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FahrstundenEvent>>(
      stream: getUserFahrstundenStream(), // Periodically fetch events
      builder: (BuildContext context,
          AsyncSnapshot<List<FahrstundenEvent>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          final events = snapshot.data!;
          return CalendarControllerProvider<FahrstundenEvent>(
            controller: EventController<FahrstundenEvent>()..addAll(events),
            child: WeekView<FahrstundenEvent>(
              weekDays: [
                WeekDays.monday,
                WeekDays.tuesday,
                WeekDays.wednesday,
                WeekDays.thursday,
                WeekDays.friday,
                WeekDays.saturday
              ],
              onEventTap: (events, date) {
                _dialogBuilder(context, events);
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, List<CalendarEventData<FahrstundenEvent>> events) {
        ParseObject obj = ParseObject("className");
        FahrstundenEvent myEvent = events.first as FahrstundenEvent;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors
              .transparent, // Dialog hintergrundfarbe wird transparenz gesetzt damit wir unseren eigenen gestalten können
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Dialog hintergrund farbe
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: tabBarMainColorShade300,
                width: 2.3,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: SizedBox(
                    height: 300,
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(events.first.title, style: TextStyle(fontSize: 25)),
                        const SizedBox(height: 5),
                        Text(events.first.description!),
                        const SizedBox(height: 15),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                           Text("Fahrzeug"),
                            const SizedBox(width: 90),
                            Text("${myEvent.schueler!.get<String>("Name")!}, ${myEvent.schueler!.get<String>("Vorname")!}"),
                          ],
                        

                        ),
                        const SizedBox(height: 15),
                        ///TODO MEIN CONTENT
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -40,
                  child: Container(
                    // Border für CircleAvatar
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: tabBarMainColorShade300,
                        width: 2.3,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: tabBarMainColorShade100,
                      radius: 40,
                      child: Icon(
                        Icons.edit_calendar,
                        size: 60,
                        color: tabBarMainColorShade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
