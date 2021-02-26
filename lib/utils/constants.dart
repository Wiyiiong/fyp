import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firestore = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final userRef = _firestore.collection('users');
final auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

// Enum Constants
/// Alert Type
final alertType_0 = 'Push Notification Alert';
final alertType_1 = 'SMS Notification Alert';
final alertType_2 = 'Email Notification Alert';

// Status Constant
/// Login Status
final successCode = 200;
final userNotFoundCode = 404;
final wrongPasswordCode = 400;
final unknownErrorCode = 000;

// Error Message
/// General
final emptyFieldErrorMsg = '{i} cannot be empty';
final lengthErrorMsg = '{i} must between {x} and {y} characters.';

/// Sign Up
final passwordErrorMsg =
    'Password must between 8 to 30 characters and contain one lowercase and uppercase alphabet and at least one digit.';
final emailErrorMsg = 'Email address is not valid. Example: abc@example.com';
final confirmPasswordErrorMsg =
    'Password and Confirm Password must be the same';

final phoneErrorMsg = 'Phone number is not valid. Example: 60123456789';

// Settings
/// Default alert time
final defaultAlertTime = "12:00";
