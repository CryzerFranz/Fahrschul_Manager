// ignore: file_names, depend_on_referenced_packages
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

class NavBarRoleInitialized extends NavBarEvent {
  final bool isFahrlehrer;

  NavBarRoleInitialized(this.isFahrlehrer);
  
  @override
  // TODO: implement props
  List<Object?> get props => [isFahrlehrer];
}

// State
abstract class NavBarState {
  final int selectedIndex;
  final bool isFahrlehrer;

  const NavBarState(this.selectedIndex, this.isFahrlehrer);
}

class NavBarInitial extends NavBarState {
  NavBarInitial(bool isFahrlehrer) : super(isFahrlehrer ? 2 : 1, isFahrlehrer);
}

class NavBarUpdated extends NavBarState {
  const NavBarUpdated(int selectedIndex, bool isFahrlehrer)
      : super(selectedIndex, isFahrlehrer);
}
