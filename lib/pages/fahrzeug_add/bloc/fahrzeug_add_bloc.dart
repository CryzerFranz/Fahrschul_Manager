import 'package:fahrschul_manager/doc/intern/Fahrzeug.dart';
import 'package:fahrschul_manager/pages/fahrzeug_add/bloc/fahrzeug_add_event.dart';
import 'package:fahrschul_manager/pages/fahrzeug_add/bloc/fahrzeug_add_state.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class FahrzeugAddBloc extends Bloc<FahrzeugAddEvent, FahrzeugAddState> {
  FahrzeugAddBloc() : super(DataLoading()) {
    on<FetchFahrzeugAddEvent>(_onFetchData);
  }

  Future<void> _onFetchData(
      FetchFahrzeugAddEvent event, Emitter<FahrzeugAddState> emit) async {
    emit(DataLoading());
    try {
      final getriebeList = await fetchAllGetriebe();
      final markeList = await fetchAllMarke();
      final fahrzeugtypList = await fetchAllFahrzeugtyp();

      emit(DataLoaded(
         getriebeList: getriebeList,
         markeList: markeList,
         fahrzeugtypList: fahrzeugtypList,

      ));
    } catch (e) {
      emit(DataError('Failed to fetch user data.'));
    }
  }
}
