import 'package:fahrschul_manager/pages/profil_page/bloc/profil_page_event.dart';
import 'package:fahrschul_manager/pages/profil_page/bloc/profil_page_state.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ProfilPageBloc extends Bloc<ProfilPageEvent, ProfilPageState> {
  ProfilPageBloc() : super(DataLoading()) {
    on<FetchProfilPageEvent>(_onFetchData);
  }

  Future<void> _onFetchData(
      FetchProfilPageEvent event, Emitter<ProfilPageState> emit) async {
    emit(DataLoading());
    try {
      final vorname = Benutzer().dbUser!.get<String>("Vorname")!;
      final nachname = Benutzer().dbUser!.get<String>("Name")!;
      final email = Benutzer().dbUser!.get<String>("Email")!;
      final fahrschuleName =
          Benutzer().fahrschule!.get<String>("Name")!;

      emit(DataLoaded(
        vorname: vorname,
        nachname: nachname,
        email: email,
        fahrschuleName: fahrschuleName,
      ));
    } catch (e) {
      emit(DataError('Failed to fetch user data.'));
    }
  }
}
