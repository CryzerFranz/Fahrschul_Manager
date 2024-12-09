import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../calendar_view_customization.dart';

abstract class CalendarEventState {}

class DataLoading extends CalendarEventState {}

class DataLoaded extends CalendarEventState {
  final List<ParseObject> fahrzeuge;
  final List<ParseObject> fahrschueler;
  final FahrstundenEvent event;

  DataLoaded(this.fahrzeuge, this.fahrschueler, this.event);
}

class DataError extends CalendarEventState {
  final String message;
  DataError(this.message);
}

class EventDataPreview extends CalendarEventState{
  EventDataPreview();
}
