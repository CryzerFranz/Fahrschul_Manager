import 'dart:ui';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../calendar_view_customization.dart';

abstract class CalendarEventState {}

class DataLoading extends CalendarEventState {}

class DataLoaded extends CalendarEventState {
  final List<ParseObject> fahrzeuge;
  final List<ParseObject> fahrschueler;
  final FahrstundenEvent event;
  final DateTime fullDate;
  final DateTime fullEndDate;
  final String dateInfo;
  final String datetimeInfo;
  final Color infoBackgroundColor;
  final Color infoBorderColor;

  DataLoaded(
      this.fahrzeuge,
      this.fahrschueler,
      this.event,
      this.fullDate,
      this.fullEndDate,
      this.dateInfo,
      this.datetimeInfo,
      this.infoBackgroundColor,
      this.infoBorderColor);
}

class SelectedEventDataState extends CalendarEventState {
  final FahrstundenEvent event;
  final DateTime fullDate;
  final DateTime fullEndDate;
  final String dateInfo;
  final String datetimeInfo;
  final Color infoBackgroundColor;
  final Color infoBorderColor;

  SelectedEventDataState(
      this.event,
      this.fullDate,
      this.fullEndDate,
      this.dateInfo,
      this.datetimeInfo,
      this.infoBackgroundColor,
      this.infoBorderColor);
}

class DataError extends CalendarEventState {
  final String message;
  DataError(this.message);
}

class EventDataPreview extends CalendarEventState {
  EventDataPreview();
}
