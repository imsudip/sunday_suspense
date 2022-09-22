import 'package:date_time_format/date_time_format.dart';

String calculateDuration(var length) {
  int hours = (length ~/ 3600);
  int minutes = (length ~/ 60) % 60;
  if (hours == 0) {
    return "$minutes mins";
  } else {
    return "$hours hrs $minutes mins";
  }
}

String showDate(String date) {
  DateTime dateTime = DateTime.parse(date);
  return DateTimeFormat.format(dateTime, format: 'jS M Y');
}
