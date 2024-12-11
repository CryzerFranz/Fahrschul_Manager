
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class CalendarEvent {}

class PrepareChangeCalendarEventData extends CalendarEvent {
  final FahrstundenEvent event;
  PrepareChangeCalendarEventData(this.event);
}

class ResetStateEvent extends CalendarEvent {
  ResetStateEvent();
}

class ExecuteChangeCalendarEventData extends CalendarEvent {
  final ParseObject? fahrzeuge;
  final ParseObject? fahrschueler;
  final String eventId;
  final String titel;
  final String description;
  final DateTime fullDate;
  final DateTime fullEndDate;
  ExecuteChangeCalendarEventData(this.eventId, this.titel, this.description, this.fullDate, this.fullEndDate, this.fahrschueler, this.fahrzeuge);
}