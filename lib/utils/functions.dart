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

  /// To format phone number string to firebase standard format
  /// eg: 60123456789 -> +60 12-345 6789
  /// eg: 601112345678 -> +60 11-1234 5678
  static formatPhoneNumber(String phone) {
    if (phone.length == 11) {
      var prefix = phone.substring(0, 2);
      var code = phone.substring(2, 4);
      var middle = phone.substring(4, 7);
      var end = phone.substring(7);

      var newPhone = "+" + prefix + " " + code + "-" + middle + " " + end;
      return newPhone;
    } else {
      var prefix = phone.substring(0, 2);
      var code = phone.substring(2, 4);
      var middle = phone.substring(4, 8);
      var end = phone.substring(8);

      var newPhone = "+" + prefix + " " + code + "-" + middle + " " + end;
      return newPhone;
    }
  }

  /// To unformat phone number string to firebase standard format
  /// eg: +60 12-345 6789 -> 60123456789
  /// eg: +60 11-1234 5678 -> 601112345678
  static unformatPhoneNumber(String phone) {
    return phone.replaceAll("+", "").replaceAll("-", "").replaceAll(" ", "");
  }
}
