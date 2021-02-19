import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_reminder/utils/constants.dart';
import '../models/userModel.dart';
import '../utils/constants.dart';

class UserService {
  static Future<User> getUserDetails(String userId) async {
    DocumentSnapshot userSnapshot = await userRef.doc(userId).get();
    return User.fromDoc(userSnapshot);
  }
}
