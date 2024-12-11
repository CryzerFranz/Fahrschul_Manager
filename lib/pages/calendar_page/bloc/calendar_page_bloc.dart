import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrstunde.dart';
import 'package:fahrschul_manager/doc/intern/Fahrzeug.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_event.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_state.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CalendarEventBloc extends Bloc<CalendarEvent, CalendarEventState> {
  CalendarEventBloc() : super(EventDataPreview()) {
    on<PrepareChangeCalendarEventData>(_fetchData);
    on<ResetStateEvent>(_resetState);
    on<ExecuteChangeCalendarEventData>(_updateFahrstunde);
  }

  Future<void> _updateFahrstunde(
      ExecuteChangeCalendarEventData event, Emitter<CalendarEventState> emit) async {
        final isUpdated = await updateFahrstunde(event: event);
        if(isUpdated){
          emit(EventDataPreview());
        }
        emit(DataError("Updating failed"));
    //emit(EventDataPreview());
  }

  Future<void> _resetState(
      ResetStateEvent event, Emitter<CalendarEventState> emit) async {
    emit(EventDataPreview());
  }

  Future<void> _fetchData(PrepareChangeCalendarEventData event,
      Emitter<CalendarEventState> emit) async {
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
      List<ParseObject> availableFahrzeuge = availableResources["Fahrzeuge"] as List<ParseObject>;
      List<ParseObject> availableSchueler = availableResources["Schueler"] as List<ParseObject>;
      // Wenn zu dem Event/Fahrstunde ein Fahrzeug oder Fahrschueler hinzugefügt wurde (davor), dann füge diesen
      // zur Liste der verfügbaren Resourcen
      if(event.event.fahrzeug != null)
      {
        availableFahrzeuge.add(event.event.fahrzeug!);
      }
      if(event.event.fahrschueler != null)
      {
        availableSchueler.add(event.event.fahrschueler!);
      }
      emit(DataLoaded(availableFahrzeuge, availableSchueler, event.event, initialStartTime, initialEndTime));
    } catch (e) {
      emit(DataError("Failed to fetch data"));
    }
  }
}
