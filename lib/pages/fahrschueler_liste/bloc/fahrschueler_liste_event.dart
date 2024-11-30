import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class FahrschuelerListEvent {}

class FetchFahrschuelerListEvent extends FahrschuelerListEvent {
  final String state;

  FetchFahrschuelerListEvent(this.state);
}

class ChangeStateFahrschuelerEvent extends FahrschuelerListEvent {
  final String stateToChange;
  final String currentState;
  final ParseObject object;

  ChangeStateFahrschuelerEvent(this.stateToChange, this.currentState, this.object);
}