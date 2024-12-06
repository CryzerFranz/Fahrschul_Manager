import 'package:calendar_view/calendar_view.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/widgets/calendar_view_customization.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
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
              headerStringBuilder: (date, {secondaryDate}) {
                return "Termine von\n${date.day}.${date.month}.${date.year} bis ${secondaryDate!.day - 1}.${secondaryDate.month}.${secondaryDate.year}";
              },
              headerStyle: const HeaderStyle(
                  decoration: BoxDecoration(color: tabBarMainColorShade100)),
              // Sonntag entfernen
              weekDays: const [
                WeekDays.monday,
                WeekDays.tuesday,
                WeekDays.wednesday,
                WeekDays.thursday,
                WeekDays.friday,
                WeekDays.saturday
              ],
              startHour: 6, // Arbeit startet erst um 06.00 Früh 
              onEventTap: (events, date) {
                _dialogBuilder(context, events);
              },
              timeLineBuilder: (date) {
                final hourFormatter = DateFormat.Hm();
                return Container(
                  height: 60,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Text(hourFormatter.format(date)),
                );
              },
              // Position korrigieren
              timeLineOffset: 30,
            ),
          );
        }
      },
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, List<CalendarEventData<FahrstundenEvent>> events) {
    FahrstundenEvent eventData = events.first as FahrstundenEvent;
    late Color infoBackgroundColor;
    late Color infoBorderColor;

    if(eventData.color == mainColor)
    {
      infoBackgroundColor = tabBarMainColorShade100;
      infoBorderColor = mainColor;
    }else if(eventData.color == mainColorComplementaryFirst){
      infoBackgroundColor = mainColorComplementaryFirstShade100;
      infoBorderColor = mainColorComplementaryFirst;
    }
    else if(eventData.color == mainColorComplementarySecond){
      infoBackgroundColor = mainColorComplementarySecondShade100;
      infoBorderColor = mainColorComplementarySecond;
    }

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
                color: infoBorderColor,
                width: 2.3,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 60.0,
                    left: 20.0,
                    right: 20.0,
                    bottom: 15.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Titel (Centered)
                      Text(
                        events.first.title,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      // Beschreibung (Left-Aligned)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Beschreibung:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(events.first.description!),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Fahrzeug und Fahrschüler Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            eventData.fahrzeug == null
                                ? "Kein Fahrzeug"
                                : "${eventData.fahrzeug!.get<ParseObject>('Marke')?.get<String>('Name') ?? ''} ${eventData.fahrzeug!.get<String>('Label') != null ? "(${eventData.fahrzeug!.get<String>('Label')})" : ''}",
                          ),
                          Text(
                            eventData.schueler == null
                                ? "Kein Fahrschüler"
                                : "${eventData.schueler!.get<String>("Name")!}, ${eventData.schueler!.get<String>("Vorname")!}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -40,
                  child: Container(
                    // Border für CircleAvatar
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: infoBorderColor,
                        width: 2.3,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: infoBackgroundColor,
                      radius: 40,
                      child: Icon(
                        Icons.edit_calendar,
                        size: 60,
                        color: infoBorderColor,
                      ),
                    ),
                  ),
                ),
                // Linker button
                Positioned(
                  top: -15,
                  left: -15,
                  child: Container(
                    // Border für CircleAvatar
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: tabBarOrangeShade300,
                        width: 2.3,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: const CircleAvatar(
                        backgroundColor: tabBarOrangeShade100,
                        radius: 15,
                        child: Icon(
                          Icons.edit,
                          color: tabBarOrangeShade300,
                        ),
                      ),
                    ),
                  ),
                ),
                // Rechter Button
                Positioned(
                  top: -15,
                  right: -15,
                  child: Container(
                    // Border für CircleAvatar
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: tabBarRedShade300,
                        width: 2.3,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const CircleAvatar(
                        backgroundColor: tabBarRedShade100,
                        radius: 15,
                        child: Icon(
                          Icons.close,
                          color: tabBarRedShade300,
                        ),
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
