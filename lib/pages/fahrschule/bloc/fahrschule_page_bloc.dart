import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_event.dart';
import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_state.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschule.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FahrschulePageBloc extends Bloc<FahrschulePageEvent, FahrschulePageState> {
  FahrschulePageBloc() : super(DataLoading()) {
    on<FetchData>(_onFetchData);
    on<PageChangedEvent>(_onPageChanged);
  }

  Future<void> _onFetchData(
      FetchData event, Emitter<FahrschulePageState> emit) async {
    emit(DataLoading());
    try {
      // Fetch the necessary data
      final fahrlehrerList = await fetchAllFahrlehrerFromFahrschule(
          Benutzer().fahrschule!.objectId!);
      final locations = await fetchAllLocationsFromFahrschule(
          id: Benutzer().fahrschule!.objectId!);

      // Emit the loaded state with default page index
      emit(DataLoaded(
        fahrlehrer: fahrlehrerList,
        locations: locations,
        currentIndex: 0,
      ));
    } catch (e) {
      // Emit an error state if the data fetching fails
      emit(DataError('Failed to fetch user data: $e'));
    }
  }

  void _onPageChanged(
      PageChangedEvent event, Emitter<FahrschulePageState> emit) {
    if (state is DataLoaded) {
      // Update the current index while retaining existing data
      final loadedState = state as DataLoaded;
      emit(DataLoaded(
        fahrlehrer: loadedState.fahrlehrer,
        locations: loadedState.locations,
        currentIndex: event.index,
      ));
    }
  }
}
