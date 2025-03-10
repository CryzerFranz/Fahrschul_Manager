 Map<String, String> generateDateTimeSummary(
      {required DateTime date,
      required DateTime endDate,
      required DateTime startTime,
      required DateTime endTime}) {
    String dateInfo = date.day == endDate.day
        ? "${date.day}.${date.month}.${date.year}"
        : "${date.day}.${date.month}.${date.year} - ${endDate.day}.${endDate.month}.${endDate.year}";
    String datetimeInfo =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
    return {"start_date": dateInfo, "time_range": datetimeInfo};
  }

  DateTime combineDateAndTime({required DateTime date, required DateTime time}) {
    return date.add(Duration(hours: time.hour, minutes: time.minute));
  }

  String generateTimeRangeText({required DateTime start, required DateTime end})
  {
     return
        "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
  }

  String generateDateRangeText({required DateTime start, required DateTime end})
  {
    return start.day == end.day
        ? "${start.day}.${start.month}.${start.year}"
        : "${start.day}.${start.month}.${start.year} - ${end.day}.${end.month}.${end.year}";
  }