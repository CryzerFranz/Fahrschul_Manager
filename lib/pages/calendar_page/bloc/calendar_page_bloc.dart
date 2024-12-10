import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrzeug.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_event.dart';
import 'package:fahrschul_manager/pages/calendar_page/bloc/calendar_page_state.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class CalendarEventBloc extends Bloc<CalendarEvent, CalendarEventState> {
  CalendarEventBloc() : super(EventDataPreview()) {
    on<PrepareChangeCalendarEventData>(_fetchData);
    on<ResetStateEvent>(_resetState);

  }

 // Future<void> _changeEventData(PrepareChangeCalendarEventData event,
 //     Emitter<CalendarEventState> emit) async {
 //   //TODO
 // }

 Future<void> _resetState(ResetStateEvent event,
      Emitter<CalendarEventState> emit) async{
            emit(EventDataPreview());
      }

  Future<void> _fetchData(PrepareChangeCalendarEventData event,
      Emitter<CalendarEventState> emit) async {
    emit(DataLoading());
    try {
      final fahrzeuge = await getAllFahrzeuge(Benutzer().fahrschule!);
      final schueler =
          await Benutzer().fetchFahrschuelerByState(state: stateActive);
      emit(DataLoaded(fahrzeuge, schueler, event.event));
    } catch (e) {
      emit(DataError("Failed to fetch data"));
    }
  }
}
