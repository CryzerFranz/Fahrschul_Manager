import 'package:calendar_view/calendar_view.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/calendar_page/AsyncEventDataValidationFormBloc.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_bloc.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_event.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_state.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
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
    String dateInfo = events.first.date.day == events.first.endDate.day
        ? "${events.first.date.day}.${events.first.date.month}.${events.first.date.year}"
        : "${events.first.date.day}.${events.first.date.month}.${events.first.date.year} - ${events.first.endDate.day}.${events.first.endDate.month}.${events.first.endDate.year}";
    String datetimeInfo =
        "${events.first.startTime!.hour}:${events.first.startTime!.minute} - ${events.first.endTime!.hour}:${events.first.endTime!.minute}";

    if (eventData.color == mainColor) {
      infoBackgroundColor = tabBarMainColorShade100;
      infoBorderColor = mainColor;
    } else if (eventData.color == mainColorComplementaryFirst) {
      infoBackgroundColor = mainColorComplementaryFirstShade100;
      infoBorderColor = mainColorComplementaryFirst;
    } else if (eventData.color == mainColorComplementarySecond) {
      infoBackgroundColor = mainColorComplementarySecondShade100;
      infoBorderColor = mainColorComplementarySecond;
    }

    return showGeneralDialog<void>(
        context: context,
        barrierDismissible:
            false, // Prevent automatic dismissal when tapping outside
        barrierLabel: "Dismiss", // Optional label for accessibility
        barrierColor: Colors.black54, // Dim background
        transitionDuration: Duration(milliseconds: 200), // Optional: animation
        pageBuilder: (BuildContext dialogContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return BlocBuilder<CalendarEventBloc, CalendarEventState>(
              builder: (context, blocState) {
            return GestureDetector(
              behavior:
                  HitTestBehavior.opaque, // Ensures taps outside are detected
              onTap: () {
                context.read<CalendarEventBloc>().add(ResetStateEvent());
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: Center(
                child: GestureDetector(
                  onTap:
                      () {}, // Prevent tap propagation to the outer GestureDetector
                  child: Dialog(
                    backgroundColor:
                        Colors.transparent, // Custom dialog background
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Dialog background color
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: infoBorderColor,
                          width: 2.3,
                        ),
                      ),
                      child: Builder(
                        builder: (context) {
                          if (blocState is DataLoading ||
                              blocState is DataLoaded) {
                            return _stackLoadingEditingWindow(blocState,
                                context, infoBorderColor, infoBackgroundColor);
                          } else {
                            return _stackEventInformation(
                                events,
                                dateInfo,
                                datetimeInfo,
                                eventData,
                                infoBorderColor,
                                infoBackgroundColor,
                                context);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  Stack _stackLoadingEditingWindow(CalendarEventState blocState,
      BuildContext context, Color infoBorderColor, Color infoBackgroundColor) {
    return Stack(
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
          child: blocState is DataLoading
              ? loadingScreen()
              : _editWindow(
                  context,
                  blocState
                      as DataLoaded), // blocState kann in diesen Moment nur DataLoaded sein
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
                Icons.edit_calendar_outlined,
                size: 60,
                color: infoBorderColor,
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
              onTap: () {
                context.read<CalendarEventBloc>().add(ResetStateEvent());
                Navigator.of(context).pop();
              },
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
    );
  }

  Stack _stackEventInformation(
      List<CalendarEventData<FahrstundenEvent>> events,
      String dateInfo,
      String datetimeInfo,
      FahrstundenEvent eventData,
      Color infoBorderColor,
      Color infoBackgroundColor,
      BuildContext context) {
    return Stack(
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
          child: _eventContent(events, dateInfo, datetimeInfo, eventData),
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
                Icons.event,
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
              onTap: () {
                context.read<CalendarEventBloc>().add(
                    PrepareChangeCalendarEventData(
                        events.first as FahrstundenEvent));
              },
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
    );
  }

  Column _eventContent(List<CalendarEventData<FahrstundenEvent>> events,
      String dateInfo, String datetimeInfo, FahrstundenEvent eventData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Titel (Centered)
        Text(
          events.first.title,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 7),
        Icon(Icons.access_time_outlined, size: 20),
        const SizedBox(height: 3),
        Text(dateInfo),
        const SizedBox(height: 3),
        Text(datetimeInfo),

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fahrzeug:", // Label
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  eventData.fahrzeug == null
                      ? "Kein Fahrzeug"
                      : "${eventData.fahrzeug!.get<ParseObject>('Marke')?.get<String>('Name') ?? ''} ${eventData.fahrzeug!.get<String>('Label') != null ? "(${eventData.fahrzeug!.get<String>('Label')})" : ''}",
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fahrschüler:", // Label
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  eventData.fahrschueler == null
                      ? "Kein Fahrschüler"
                      : "${eventData.fahrschueler!.get<String>("Name")!}, ${eventData.fahrschueler!.get<String>("Vorname")!}",
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  _editWindow(BuildContext context, DataLoaded blocState) {
    return BlocProvider(
        create: (context) => AsyncEventDataValidationFormBloc(
            title: blocState.event.title,
            startDateTime: blocState.fullDate,
            endDateTime: blocState.fullEndDate,
            fahrzeuge: blocState.fahrzeuge,
            fahrschueler: blocState.fahrschueler,
            selectedFahrzeug: blocState.event.fahrzeug != null ? true : false,
            selectedFahrschueler:
                blocState.event.fahrschueler != null ? true : false,
            description: blocState.event.description),
        child: Builder(builder: (context) {
          final formBloc = context.read<AsyncEventDataValidationFormBloc>();
          return FormBlocListener<AsyncEventDataValidationFormBloc, String,
              String>(
            formBloc: formBloc,
            onSuccess: (context, state) async {
              //TODO event triggern zum speichern der DATEN
                context.read<CalendarEventBloc>().add(ExecuteChangeCalendarEventData(blocState.event.eventID, formBloc.titleFormBloc.value, formBloc.descriptionFormBloc.value, formBloc.startDateTimeFormBloc.value, formBloc.endDateTimeFormBloc.value, formBloc.fahrschuelerDropDownBloc.value, formBloc.fahrzeugDropDownBloc.value));
            },
            onFailure: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                    showErrorSnackbar(state.failureResponse!, "Fehler SECOND"));
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titel (Centered)
                  TextFieldBlocBuilder(
                    textFieldBloc: formBloc.titleFormBloc,
                    decoration: inputDecoration("Titel"),
                  ),
                  const SizedBox(height: 7),
                  DateTimeFieldBlocBuilder(
                    dateTimeFieldBloc: formBloc.startDateTimeFormBloc,
                    canSelectTime: true,
                    format: DateFormat(
                      'dd-MM-yyyy  HH:mm',
                    ),
                    initialDate: blocState.event.date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    decoration: const InputDecoration(
                      labelText: 'Start',
                      prefixIcon: Icon(Icons.calendar_today),
                      helperText: 'Start Zeit des Termins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  DateTimeFieldBlocBuilder(
                    dateTimeFieldBloc: formBloc.endDateTimeFormBloc,
                    canSelectTime: true,
                    format: DateFormat('dd-MM-yyyy  HH:mm'),
                    initialDate: blocState.event.endDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    decoration: const InputDecoration(
                      labelText: 'Ende',
                      prefixIcon: Icon(Icons.calendar_today),
                      helperText: 'End Zeit des Termins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Beschreibung:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFieldBlocBuilder(
                    textFieldBloc: formBloc.descriptionFormBloc,
                    decoration: inputDecoration("Description"),
                    maxLines: 5,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Fahrzeug:", // Label
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownFieldBlocBuilder(
                    selectFieldBloc: formBloc.fahrzeugDropDownBloc,
                    itemBuilder: (context, value) => FieldItem(
                      child: Text(
                          "${value.get<ParseObject>("Marke")!.get<String>("Name")!}, (${value.get<String>("Label")!})"),
                    ),
                    decoration: const InputDecoration(
                      labelText: "Fahrzeug wählen",
                      prefixIcon: Icon(Icons.directions_car),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1),
                      ),
                      // Optional: Customize the hintText or other properties if needed
                    ),
                  ),
                  const Text(
                    "Fahrschüler:", // Label
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownFieldBlocBuilder(
                    selectFieldBloc: formBloc.fahrschuelerDropDownBloc,
                    itemBuilder: (context, value) => FieldItem(
                      child: Text(
                          "${value.get<String>("Name")!}, ${value.get<String>("Vorname")!}"),
                    ),
                    decoration: const InputDecoration(
                      labelText: "Schüler wählen",
                      prefixIcon: Icon(Icons.directions_car),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1),
                      ),
                      // Optional: Customize the hintText or other properties if needed
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: formBloc.submit,
                    child: Text("Ändern"),
                    style: stadiumButtonStyle(),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
