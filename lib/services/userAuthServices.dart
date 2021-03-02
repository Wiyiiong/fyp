import 'package:expiry_reminder/utils/constants.dart';
import 'package:expiry_reminder/utils/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:flutter_twitter_login/flutter_twitter_login.dart';

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
      await auth.currentUser.sendEmailVerification().then((value) async {
        await userRef
            .doc(auth.currentUser.uid)
            .update({'isEmailVerify': true, 'email': auth.currentUser.email});
      });
    }
  }

  static Future<String> signUpEmail(
      String username, String email, String password, String phone) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userRef.doc(userCredential.user.uid).set({
        'name': username,
        'email': email,
        'phoneNumber': UtilFunctions.formatPhoneNumber(phone),
        'preferredAlertTime': defaultAlertTime,
        'createdDatetime': DateTime.now().millisecondsSinceEpoch,
        'modifyDatetime': DateTime.now().millisecondsSinceEpoch,
        'isDeleted': false,
        'isEmailVerify': false,
        'isPhoneVerify': false,
      });

      return userCredential.user.uid;
    } catch (e) {
      print(e.message);
    }
    return null;
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

  static Future phoneVerified(String userId, String phoneNumber) async {
    await userRef.doc(userId).update({
      'isPhoneVerify': true,
      'phoneNumber': UtilFunctions.formatPhoneNumber(phoneNumber)
    }).catchError((e) => print(e.message));
  }

  static Future verifyOTP({String smsCode, String verificationId}) async {
    try {
      var credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode.trim());

      await auth.currentUser
          .updatePhoneNumber(credential)
          .catchError((e) => print(e.message));
    } catch (e) {
      print(e);
    }

    // auth.signInWithCredential(credential).then((value) async {
    //   auth.currentUser
    //       .linkWithCredential(credential)
    //       .catchError((e) => print(e.message));
    // }).catchError((e) => print(e.message));
  }

  static Future signInWithFacebook() async {
    final AccessToken result = await FacebookAuth.instance.login();
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.token);
    final user = await auth.signInWithCredential(facebookAuthCredential);

    if (user.user != null) {
      var userDoc = await userRef.doc(user.user.uid).get();
      if (!userDoc.exists) {
        await userRef.doc(user.user.uid).set({
          'name': user.user.displayName,
          'email': user.user.email,
          'phoneNumber': user.user.phoneNumber,
          'preferredAlertTime': defaultAlertTime,
          'createdDatetime': DateTime.now().millisecondsSinceEpoch,
          'modifyDatetime': DateTime.now().millisecondsSinceEpoch,
          'isDeleted': false,
          'isEmailVerify': user.user.email != null,
          'isPhoneVerify': user.user.phoneNumber != null,
        });
      }
    }
    return user.user.uid;
  }

//   static Future<String> signInWithTwitter() async {
//     // Create a TwitterLogin instance
//     final TwitterLogin twitterLogin = new TwitterLogin(
//       consumerKey: 'YKT7007L5CBRcu9RnhHVK1mvB',
//       consumerSecret: 'MHPp7s45ML9CVGaYQ4qrJWeNSgHUdGR1JNPH4A8DFyfOQUipF4',
//     );

//     // Trigger the sign-in flow
//     final TwitterLoginResult result =
//         await twitterLogin.authorize().catchError((e) => print(e.message));

//     // Get the Logged In session
//     final TwitterSession twitterSession = result.session;

//     final userStatus = result.status;

//     if (userStatus == TwitterLoginStatus.loggedIn) {
// // Create a credential from the access token
//       final AuthCredential twitterAuthCredential =
//           TwitterAuthProvider.credential(
//               accessToken: twitterSession.token ?? "",
//               secret: twitterSession.secret ?? "");

//       // Once signed in, return the UserCredential
//       final user = await auth.signInWithCredential(twitterAuthCredential);

//       if (user.user != null) {
//         var userDoc = await userRef.doc(user.user.uid).get();
//         if (!userDoc.exists) {
//           await userRef.doc(user.user.uid).set({
//             'name': user.user.displayName,
//             'email': user.user.email,
//             'phoneNumber': user.user.phoneNumber,
//             'preferredAlertTime': defaultAlertTime,
//             'createdDatetime': DateTime.now().millisecondsSinceEpoch,
//             'modifyDatetime': DateTime.now().millisecondsSinceEpoch,
//             'isDeleted': false,
//             'isEmailVerify': user.user.email != null,
//             'isPhoneVerify': user.user.phoneNumber != null,
//           });
//         }
//       }
//       return user.user.uid;
//     }

//     return null;
//   }
}
