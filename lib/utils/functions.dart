import 'package:flutter/material.dart';

class UtilFunctions {
  static String capitalizeWord(String word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  static TimeOfDay convertStrToTime(String time) {
    int hour = int.parse(time.split(':').first);
    int minute = int.parse(time.split(':').last);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
