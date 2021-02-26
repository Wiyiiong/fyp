import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      'facebookToken': "",
      'twitterToken': "",
      'gmailToken': "",
      'modifyDatetime': DateTime.now().millisecondsSinceEpoch,
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

  static Future<String> signInGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      var userDoc = await userRef.doc(user.uid).get();
      if (!userDoc.exists) {
        await userRef.doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'preferredAlertTime': defaultAlertTime,
          'createdDatetime': DateTime.now().millisecondsSinceEpoch,
          'facebookToken': "",
          'twitterToken': "",
          'gmailToken': "",
          'modifyDatetime': DateTime.now().millisecondsSinceEpoch,
          'isDeleted': false,
          'isEmailVerify': true,
          'isPhoneVerify': false,
        });
      }

      return user.uid;
    }

    return null;
  }
}
