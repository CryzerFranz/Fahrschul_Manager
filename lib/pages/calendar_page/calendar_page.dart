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

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FahrstundenEvent>>(
      stream: getUserFahrstundenStream(),
      builder: (BuildContext context,
          AsyncSnapshot<List<FahrstundenEvent>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          final events = snapshot.data!;
          return Stack(
            children: [
              CalendarControllerProvider<FahrstundenEvent>(
                controller: EventController<FahrstundenEvent>()..addAll(events),
                child: WeekView<FahrstundenEvent>(
                  headerStringBuilder: (date, {secondaryDate}) {
                    return "Termine von\n${date.day}.${date.month}.${date.year} bis ${secondaryDate!.day - 1}.${secondaryDate.month}.${secondaryDate.year}";
                  },
                  headerStyle: const HeaderStyle(
                    decoration: BoxDecoration(color: tabBarMainColorShade100),
                  ),
                  // Ohne Sonntage
                  weekDays: const [
                    WeekDays.monday,
                    WeekDays.tuesday,
                    WeekDays.wednesday,
                    WeekDays.thursday,
                    WeekDays.friday,
                    WeekDays.saturday
                  ],
                  startHour:
                      6, // Kalendar zeigt erst ab 06:00 Uhr frühs an bis 24:00
                  onEventTap: (events, date) {
                    _dialogBuilder(context, events);
                  },
                  onDateTap: (date) {
                    // Neues event erstellen
                    _dialogBuilder(context, [], date: date);
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
                  // Zeit position korrigieren
                  timeLineOffset: 30,
                  // hervorheben des aktuellen wochentages
                  weekDayBuilder: (date) {
                    final isToday = date.isSameDate(DateTime.now());
                    final dayLetter =
                        DateFormat.E().format(date)[0].toUpperCase();

                    return Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? mainColorComplementaryFirst
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            // Erster Buchstabe des Tages
                            dayLetter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 120.0,
                right: 16.0,
                child: ElevatedButton(
                  onPressed: () {
                      _dialogBuilder(context, [], date: DateTime.now());
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16.0),
                    backgroundColor:
                        mainColor, // Replace with your preferred color
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Dialog Fenster wenn auf ein Event oder leeres Zeitfenster oder auf das + getippt wird
  Future<void> _dialogBuilder(
      BuildContext context, List<CalendarEventData<FahrstundenEvent>> events,
      {DateTime? date}) {
    return showGeneralDialog<void>(
        context: context,
        barrierDismissible:
            false, 
        barrierLabel: "Dismiss", 
        barrierColor: Colors.black54, 
        transitionDuration:
            const Duration(milliseconds: 200), 
        pageBuilder: (BuildContext dialogContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
              // wenn das Ereignis leer ist und das Datum angegeben ist, dann ist dies eine Erstellung
              // andernfalls wird eine detaillierte Ansicht des ausgewählten Ereignisses gewünscht
              if(events.isEmpty && date != null)
              {
                context
                .read<CalendarEventBloc>()
                .add(CreateEvent(date));
              }else{
                context
                .read<CalendarEventBloc>()
                .add(PrepareCalendarEventViewData(events.first as FahrstundenEvent));
              }
          
          return BlocBuilder<CalendarEventBloc, CalendarEventState>(
              builder: (context, blocState) {

            return GestureDetector(
              behavior:
                  HitTestBehavior.opaque,
              onTap: () {
                context.read<CalendarEventBloc>().add(ResetStateEvent());
                Navigator.of(dialogContext).pop(); 
              },
              child: Center(
                child: GestureDetector(
                  onTap:
                      () {}, // Verhinderung der Weitergabe von Antippen an den äußeren GestureDetector
                  child: Dialog(
                    backgroundColor:
                        Colors.transparent, 
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: blocState is SelectedEventDataState
                              ? blocState.infoBorderColor
                              : Colors.blueGrey,
                          width: 2.3,
                        ),
                      ),
                      child: Builder(
                        builder: (context) {
                          if (blocState is DataLoading ||
                              blocState is DataLoaded) {
                            return _stackLoadingEditingWindow(
                                blocState, context);
                          } else if (blocState is SelectedEventDataState) {
                            return _stackEventInformation(
                               blocState, context);
                          } else {
                            return const Center(child: Text("Error"));
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

  Stack _stackLoadingEditingWindow(
      CalendarEventState blocState, BuildContext context) {
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
                color: blocState is DataLoading
                    ? Colors.blueGrey
                    : (blocState as DataLoaded)
                        .infoBorderColor,
                width: 2.3,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: blocState is DataLoading
                  ? Colors.blueGrey
                  : (blocState as DataLoaded).infoBackgroundColor, 
              radius: 40,
              child: Icon( blocState is DataLoaded ?
                Icons.edit_calendar_outlined : Icons.sync,
                size: 60,
                color: blocState is DataLoading
                    ? Colors.grey[300]
                    : (blocState as DataLoaded).infoBorderColor,
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
      SelectedEventDataState blocState, BuildContext context) {
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
          child: _eventContent(
              blocState.dateInfo, blocState.datetimeInfo, blocState.event),
        ),
        Positioned(
          top: -40,
          child: Container(
            // Border für CircleAvatar
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: blocState.infoBorderColor,
                width: 2.3,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: blocState.infoBackgroundColor,
              radius: 40,
              child: Icon(
                Icons.event,
                size: 60,
                color: blocState.infoBorderColor,
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
                context
                    .read<CalendarEventBloc>()
                    .add(PrepareChangeCalendarEventViewData(blocState.event));
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

  Column _eventContent(
      String dateInfo, String datetimeInfo, FahrstundenEvent eventData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Titel (Centered)
        Text(
          eventData.title,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 7),
        const Icon(Icons.access_time_outlined, size: 20),
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
                  Text(eventData.description!),
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
        create: (context) => AsyncEventDataValidationFormBloc(),
        child: Builder(builder: (context) {
          final formBloc = context.read<AsyncEventDataValidationFormBloc>();

          // Werte initialisieren
          formBloc.titleFormBloc.updateInitialValue(blocState.event.title);
          formBloc.startDateTimeFormBloc.updateInitialValue(blocState.fullDate);
          formBloc.endDateTimeFormBloc
              .updateInitialValue(blocState.fullEndDate);
          formBloc.fahrzeugDropDownBloc.updateItems(blocState.fahrzeuge);
          formBloc.fahrzeugDropDownBloc.updateInitialValue(
              blocState.event.fahrzeug != null
                  ? blocState.fahrzeuge.last
                  : null);
          formBloc.fahrschuelerDropDownBloc.updateItems(blocState.fahrschueler);
          formBloc.fahrschuelerDropDownBloc.updateInitialValue(
              blocState.event.fahrschueler != null
                  ? blocState.fahrschueler.last
                  : null);
          formBloc.descriptionFormBloc
              .updateInitialValue(blocState.event.description ?? "");

          return FormBlocListener<AsyncEventDataValidationFormBloc, String,
              String>(
            formBloc: formBloc,
            onSuccess: (context, state) async {
              context.read<CalendarEventBloc>().add(
                  ExecuteChangeCalendarEventData(
                      blocState.event.eventID,
                      formBloc.titleFormBloc.value,
                      formBloc.descriptionFormBloc.value,
                      formBloc.startDateTimeFormBloc.value,
                      formBloc.endDateTimeFormBloc.value,
                      formBloc.fahrschuelerDropDownBloc.value,
                      formBloc.fahrzeugDropDownBloc.value));
            },
            onFailure: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                    showErrorSnackbar(state.failureResponse!, "Fehler"));
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: formBloc.submit,
                    style: stadiumButtonStyle(),
                    child: const Text("Ändern"),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
