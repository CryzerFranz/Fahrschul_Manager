import 'dart:ui';

import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrstunde.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_event.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_state.dart';
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:fahrschul_manager/src/utils/date.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CalendarEventBloc extends Bloc<CalendarEvent, CalendarEventState> {
  CalendarEventBloc() : super(EventDataPreview()) {
    on<PrepareChangeCalendarEventViewData>(_fetchData);
    on<ResetStateEvent>(_resetState);
    on<ExecuteChangeCalendarEventData>(_updateOrAddFahrstunde);
    on<CreateEvent>(_prepareNewEventData);
    on<PrepareCalendarEventViewData>(_prepareEventViewData);
  }

  Future<void> _prepareEventViewData(PrepareCalendarEventViewData event,
      Emitter<CalendarEventState> emit) async {
    final Map<String, Color> colors = getColorMapping(event.event.color);
    emit(DataLoading());
    try {
      final Map<String, String> dates = generateDateTimeSummary(
          date: event.event.date,
          endDate: event.event.endDate,
          endTime: event.event.endTime!,
          startTime: event.event.startTime!);
      final initialStartTime =
          combineDateAndTime(date: event.event.date, time: event.event.startTime!);
      final initialEndTime =
          combineDateAndTime(date: event.event.date, time: event.event.endTime!);

      emit(SelectedEventDataState(
          event.event,
          initialStartTime,
          initialEndTime,
          dates["start_date"]!,
          dates["time_range"]!,
          colors["background"]!,
          colors["border"]!));
    } catch (e) {
      emit(DataError("Preparing Data for creating failed"));
    }
  }

  Future<void> _prepareNewEventData(
      CreateEvent event, Emitter<CalendarEventState> emit) async {
    try {
      final DateTime endTime = event.time.add(const Duration(minutes: 90));
      FahrstundenEvent newEvent = FahrstundenEvent(
          eventID: null,
          title: "",
          startTime: event.time,
          endTime: endTime,
          endDate: endTime,
          date: event.time);
      add(PrepareChangeCalendarEventViewData(newEvent));
    } catch (e) {
      emit(DataError("Preparing Data for creating failed"));
    }
  }

  Future<void> _updateOrAddFahrstunde(ExecuteChangeCalendarEventData event,
      Emitter<CalendarEventState> emit) async {
    try {
      if (event.eventId != null) {
        final FahrstundenEvent? updatedEvent =
            await updateFahrstunde(event: event);
        if (updatedEvent != null) {
          add(PrepareCalendarEventViewData(updatedEvent));
        } else {
          throw ();
        }
      }else{
       final createdEvent =  await addFahrstunde(date: event.fullDate, endDate: event.fullEndDate, title: event.titel,
        description: event.description, fahrschueler: event.fahrschueler, fahrzeug: event.fahrzeug);
          add(PrepareCalendarEventViewData(createdEvent));
        
      }
    } catch (e) {
      emit(DataError("Updating failed"));
    }
  }

  Future<void> _resetState(
      ResetStateEvent event, Emitter<CalendarEventState> emit) async {
    emit(EventDataPreview());
  }

  Future<void> _fetchData(PrepareChangeCalendarEventViewData event,
      Emitter<CalendarEventState> emit) async {
    final Map<String, Color> colors = getColorMapping(event.event.color);
    emit(DataLoading());
    try {
      // Vollstände Datum
      final initialStartTime = event.event.date.add(Duration(
          hours: event.event.startTime!.hour,
          minutes: event.event.startTime!.minute));
      // Vollstände EndDatum
      final initialEndTime = event.event.date.add(Duration(
          hours: event.event.endTime!.hour,
          minutes: event.event.endTime!.minute));
      // Hole alle verfügbaren Resourcen (Fahrzeug, Fahrschueler)
      final Map<String, List<ParseObject>> availableResources =
          await fetchAvailableResourcesInRange(
              start: initialStartTime, end: initialEndTime);
      List<ParseObject> availableFahrzeuge =
          availableResources["Fahrzeuge"] as List<ParseObject>;
      List<ParseObject> availableSchueler =
          availableResources["Schueler"] as List<ParseObject>;
      // Wenn zu dem Event/Fahrstunde ein Fahrzeug oder Fahrschueler hinzugefügt wurde (davor), dann füge diesen
      // zur Liste der verfügbaren Resourcen
      if (event.event.fahrzeug != null) {
        availableFahrzeuge.add(event.event.fahrzeug!);
      }
      if (event.event.fahrschueler != null) {
        availableSchueler.add(event.event.fahrschueler!);
      }
      final Map<String, String> dates = generateDateTimeSummary(
          date: event.event.date,
          endDate: event.event.endDate,
          endTime: event.event.endTime!,
          startTime: event.event.startTime!);
      emit(DataLoaded(
          availableFahrzeuge,
          availableSchueler,
          event.event,
          initialStartTime,
          initialEndTime,
          dates["start_date"]!,
          dates["time_range"]!,
          colors["background"]!,
          colors["border"]!));
    } catch (e) {
      emit(DataError("Failed to fetch data"));
    }
  }

 

  Map<String, Color> getColorMapping(Color inputColor) {
  final colorMappings = {
    mainColor: {
      "background": tabBarMainColorShade100,
      "border": mainColor,
    },
    mainColorComplementaryFirst: {
      "background": mainColorComplementaryFirstShade100,
      "border": mainColorComplementaryFirst,
    },
    mainColorComplementarySecond: {
      "background": mainColorComplementarySecondShade100,
      "border": mainColorComplementarySecond,
    },
    tabBarRedShade300: {
      "background": tabBarRedShade100,
      "border": tabBarRedShade300,
    }
  };

  // default Color falls keine passende gefunden
  return colorMappings[inputColor] ??
      {
        "background": tabBarMainColorShade100,
        "border": mainColor,
      };
}
}
