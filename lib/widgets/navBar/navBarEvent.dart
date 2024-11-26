import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Event
abstract class NavBarEvent extends Equatable {
  const NavBarEvent();
}

class NavBarItemTapped extends NavBarEvent {
  final int index;

  const NavBarItemTapped(this.index);

  @override
  List<Object> get props => [index];
}

// State
class NavBarState extends Equatable {
  final int selectedIndex;

  const NavBarState(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
