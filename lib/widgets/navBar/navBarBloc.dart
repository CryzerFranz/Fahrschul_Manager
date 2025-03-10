import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarEvent.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class NavBarBloc extends Bloc<NavBarEvent, NavBarState> {
  NavBarBloc() : super(NavBarInitial(Benutzer().isFahrlehrer!)) {
    on<NavBarItemTapped>((event, emit) {
      final currentState = state;
      emit(NavBarUpdated(event.index, currentState.isFahrlehrer));
    });

    on<NavBarRoleInitialized>((event, emit) {
      emit(NavBarUpdated(state.selectedIndex, event.isFahrlehrer));
    });
  }
}

