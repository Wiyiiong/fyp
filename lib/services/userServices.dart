import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:flutter/material.dart';
import '../models/userModel.dart';
import '../utils/constants.dart';

class UserService {
  static Future<User> getUserDetails(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await userRef.doc(userId).get();
      return User.fromDoc(userSnapshot);
    } catch (e) {
      print(e.message);
    }
    return null;
  }

  static Future changeAlertTime(String userId, TimeOfDay alertTime) async {
    String time = "${alertTime.hour}:${alertTime.minute}";
    try {
      await userRef.doc(userId).update({'preferredAlertTime': time}).catchError(
          (e) => print(e.message));
    } catch (e) {
      print(e.message);
    }
  }
}
