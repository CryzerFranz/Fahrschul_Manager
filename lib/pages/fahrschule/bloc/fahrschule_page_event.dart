abstract class FahrschulePageEvent {}

class FetchData extends FahrschulePageEvent {
  FetchData();
}

class PageChangedEvent extends FahrschulePageEvent {
  final int index;
  PageChangedEvent(this.index);
}