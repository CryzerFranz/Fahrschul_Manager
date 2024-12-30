abstract class FuhrparkEvent {}

class FetchFuhrparkEvent extends FuhrparkEvent {
  final String state;
  

  FetchFuhrparkEvent(this.state);
}

