import 'package:fahrschul_manager/widgets/navBar/navBarEvent.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class NavBarBloc extends Bloc<NavBarEvent, NavBarState> {
  NavBarBloc() : super(const NavBarState(2)) {
    // Use the on<EventType> syntax to register the event handler
    on<NavBarItemTapped>((event, emit) {
      emit(NavBarState(event.index));
    });
  }
}
