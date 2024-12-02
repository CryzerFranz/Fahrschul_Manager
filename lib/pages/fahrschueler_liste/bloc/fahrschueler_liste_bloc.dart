import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_event.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_state.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschueler.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class FahrschuelerListBloc
    extends Bloc<FahrschuelerListEvent, FahrschuelerListState> {
  FahrschuelerListBloc() : super(DataLoading()) {
    on<FetchFahrschuelerListEvent>(_onFetchData);

    on<ChangeStateFahrschuelerEvent>(_changeStateOfFahrschueler);
  }

  Future<void> _onFetchData(FetchFahrschuelerListEvent event,
      Emitter<FahrschuelerListState> emit) async {
    emit(DataLoading());
    try {
      // Replace with your actual data fetching logic
      final data =
          await Benutzer().fetchFahrschuelerByState(state: event.state);
      if (data.isEmpty) {
        emit(DataError('No data available'));
      } else {
        emit(DataLoaded(data));
      }
    } catch (e) {
      emit(DataError('Failed to fetch data'));
    }
  }

  Future<void> _changeStateOfFahrschueler(ChangeStateFahrschuelerEvent event,
      Emitter<FahrschuelerListState> emit) async {
    emit(DataLoading());
    try {
      final bool? isUpdated = await updateFahrschuelerState(
          fahrschueler: event.object, state: event.stateToChange);
      if (isUpdated != null && isUpdated) {
        add(FetchFahrschuelerListEvent(event.currentState));
      }
    } catch (e) {
      emit(DataError("Fehler"));
    }
  }
}
