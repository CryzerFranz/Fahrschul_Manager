import 'dart:ui';

import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrstunde.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_event.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_state.dart';
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CalendarEventBloc extends Bloc<CalendarEvent, CalendarEventState> {
  CalendarEventBloc() : super(EventDataPreview()) {
    on<PrepareChangeCalendarEventViewData>(_fetchData);
    on<ResetStateEvent>(_resetState);
    on<ExecuteChangeCalendarEventData>(_updateFahrstunde);
    on<CreateEvent>(_prepareEventData);
    on<PrepareCalendarEventViewData>(_prepareEventViewData);
  }

  Map<String, Color> _getCorrectColor(Color color)
  {
        Color infoBackgroundColor = tabBarMainColorShade100;
        Color infoBorderColor = mainColor;
        if (color == mainColorComplementaryFirst) {
              infoBackgroundColor = mainColorComplementaryFirstShade100;
              infoBorderColor = mainColorComplementaryFirst;
            } else if (color == mainColorComplementarySecond) {
              infoBackgroundColor = mainColorComplementarySecondShade100;
              infoBorderColor = mainColorComplementarySecond;
            }
        return {"background": infoBackgroundColor, "border": infoBorderColor};
  }

  Future<void> _prepareEventViewData(PrepareCalendarEventViewData event,
      Emitter<CalendarEventState> emit) async {
      final Map<String, Color> colors = _getCorrectColor(event.event.color);
      emit(DataLoading());
        try{
        //final DateTime endTime =  event.time.add(const Duration(minutes: 90));
        final Map<String, String> dates = createDateTimeinfo(date: event.event.date, endDate: event.event.endDate, endTime: event.event.endTime!, startTime: event.event.startTime!);
        final initialStartTime = createDateTime(date: event.event.date, time: event.event.startTime! );
        final initialEndTime = createDateTime(date: event.event.date, time: event.event.endTime! );

        //FahrstundenEvent newEvent = FahrstundenEvent(eventID: null, title: "", startTime: event.event., endTime: endTime, endDate: endTime, date: event.time);
        emit(SelectedEventDataState(event.event,
          initialStartTime, initialEndTime, dates["Start_Date"]!, dates["Start_Time"]!,colors["background"]!, colors["border"]!));
        }catch(e)
        {
          emit(DataError("Preparing Data for creating failed"));
        }
      }

  Future<void> _prepareEventData(CreateEvent event,
      Emitter<CalendarEventState> emit) async {
        try{
        final DateTime endTime =  event.time.add(const Duration(minutes: 90));
        FahrstundenEvent newEvent = FahrstundenEvent(eventID: null, title: "", startTime: event.time, endTime: endTime, endDate: endTime, date: event.time);
        add(PrepareChangeCalendarEventViewData(newEvent));

        }catch(e)
        {
          emit(DataError("Preparing Data for creating failed"));
        }
      }

  Future<void> _updateFahrstunde(ExecuteChangeCalendarEventData event,
      Emitter<CalendarEventState> emit) async {
    try {
      final FahrstundenEvent? updatedEvent =
          await updateFahrstunde(event: event);
      if (updatedEvent != null) {
        emit(EventDataPreviewAfterUpdating(updatedEvent));
      } else {
        throw ();
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
    final Map<String, Color> colors = _getCorrectColor(event.event.color);
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
      final Map<String, String> dates = createDateTimeinfo(date: event.event.date, endDate: event.event.endDate, endTime: event.event.endTime!, startTime: event.event.startTime!);
      emit(DataLoaded(availableFahrzeuge, availableSchueler, event.event,
          initialStartTime, initialEndTime, dates["Start_Date"]!, dates["Start_Time"]!, colors["background"]!, colors["border"]!));
    } catch (e) {
      emit(DataError("Failed to fetch data"));
    }
  }

  Map<String, String> createDateTimeinfo({required DateTime date, required DateTime endDate, required DateTime startTime, required DateTime endTime})
  {
     String dateInfo = date.day == endDate.day
        ? "${date.day}.${date.month}.${date.year}"
        : "${date.day}.${date.month}.${date.year} - ${endDate.day}.${endDate.month}.${endDate.year}";
    String datetimeInfo =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
    return {"Start_Date": dateInfo, "Start_Time": datetimeInfo};
  }

  DateTime createDateTime({required DateTime date, required DateTime time})
  {
    return date.add(Duration(
          hours: time.hour,
          minutes: time.minute));
  }
}
