
import 'package:fahrschul_manager/pages/calendar_page/calendar_view_customization.dart';

abstract class CalendarEvent {}

class PrepareChangeCalendarEventData extends CalendarEvent {
  final FahrstundenEvent event;
  PrepareChangeCalendarEventData(this.event);
}

class ResetStateEvent extends CalendarEvent {
  ResetStateEvent();
}

class ExecuteChangeCalendarEventData extends CalendarEvent {
  final FahrstundenEvent event;
  ExecuteChangeCalendarEventData(this.event);
}