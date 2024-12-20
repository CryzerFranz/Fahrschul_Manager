
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class CalendarEvent {}

class PrepareChangeCalendarEventViewData extends CalendarEvent {
  final FahrstundenEvent event;
  PrepareChangeCalendarEventViewData(this.event);
}

class PrepareCalendarEventViewData extends CalendarEvent {
  final FahrstundenEvent event;
  PrepareCalendarEventViewData(this.event);
}

class ResetStateEvent extends CalendarEvent {
  ResetStateEvent();
}

class CreateEvent extends CalendarEvent {
  final DateTime time;
  CreateEvent(this.time);
}

class ExecuteChangeCalendarEventData extends CalendarEvent {
  final ParseObject? fahrzeuge;
  final ParseObject? fahrschueler;
  final String? eventId;
  final String titel;
  final String description;
  final DateTime fullDate;
  final DateTime fullEndDate;
  ExecuteChangeCalendarEventData(this.eventId, this.titel, this.description, this.fullDate, this.fullEndDate, this.fahrschueler, this.fahrzeuge);
}