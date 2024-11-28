import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_event.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_state.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class FahrschuelerListBloc extends Bloc<FahrschuelerListEvent, FahrschuelerListState> {
  FahrschuelerListBloc() : super(DataLoading()) {
    on<FetchFahrschuelerListEvent>(_onFetchData);
  }

  Future<void> _onFetchData(FetchFahrschuelerListEvent event, Emitter<FahrschuelerListState> emit) async {
    emit(DataLoading());
    try {
      // Replace with your actual data fetching logic
      final data = await Benutzer().getAllFahrschueler(state: event.state);
      if (data.isEmpty) {
        emit(DataError('No data available'));
      } else {
        emit(DataLoaded(data));
      }
    } catch (e) {
      emit(DataError('Failed to fetch data'));
    }
  }
}