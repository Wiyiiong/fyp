import 'package:expiry_reminder/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAuthService {
  static Future<Map<int, String>> signInEmail(
      String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return {successCode: userCredential.user.uid};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {userNotFoundCode: 'No user found for that email'};
      } else if (e.code == 'wrong-password') {
        return {wrongPasswordCode: 'Wrong password provided for that user.'};
      }
    }
    return {unknownErrorCode: 'Some error occurred, please try again later.'};
  }

  static Future<void> verifyUserEmail() async {
    if (!auth.currentUser.emailVerified) {
      await auth.currentUser.sendEmailVerification();
    }
  }

  static Future<String> signUpEmail(
      String username, String email, String password, String phone) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await userRef.doc(userCredential.user.uid).set({
      'name': username,
      'email': email,
      'phoneNumber': phone,
      'preferredAlertTime': defaultAlertTime,
      'createdDatetime': DateTime.now().millisecondsSinceEpoch,
      'facebookToken': null,
      'twitterToken': null,
      'gmailToken': null,
      'modifyDatetime': null,
      'isDeleted': false,
      'isEmailVerify': false,
      'isPhoneVerify': false,
    });
    return userCredential.user.uid;
  }

  static Future<void> signOut() async {
    return auth.signOut();
  }

  static User getCurrentUser() {
    User user = auth.currentUser;
    return user;
  }
}
