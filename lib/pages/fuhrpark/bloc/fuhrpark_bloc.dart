import 'package:fahrschul_manager/doc/intern/Fahrzeug.dart';
import 'package:fahrschul_manager/pages/fuhrpark/bloc/fuhrpark_event.dart';
import 'package:fahrschul_manager/pages/fuhrpark/bloc/fuhrpark_state.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FuhrparkBloc extends Bloc<FuhrparkEvent, FuhrparkState> {
  FuhrparkBloc() : super(DataLoading()) {
    on<FetchFuhrparkEvent>(_onFetchData);
  }

  Future<void> _onFetchData(
      FetchFuhrparkEvent event, Emitter<FuhrparkState> emit) async {
    emit(DataLoading());
    try {
      // Logik für das Abrufen der Benutzerdaten
      List<ParseObject> fahrzeuginfos= await fetchAllFahrzeug(Benutzer().fahrschule!);

      emit(DataLoaded(
         fahrzeuginfos: fahrzeuginfos,
      ));
    } catch (e) {
      emit(DataError('Failed to fetch user data.'));
    }
  }
}
