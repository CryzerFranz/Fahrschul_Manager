abstract class FahrschuelerListEvent {}

class FetchFahrschuelerListEvent extends FahrschuelerListEvent {
  final String state;

  FetchFahrschuelerListEvent(this.state);
}