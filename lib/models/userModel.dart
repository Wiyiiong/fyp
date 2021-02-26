import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String facebookToken;
  final String gmailToken;
  final String twitterToken;
  final bool isEmailVerify;
  final bool isPhoneVerify;
  final bool isDeleted;
  final String preferredAlertTime;
  final DateTime createdDateTime;
  final DateTime modifiedDateTime;

  User(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.facebookToken,
      this.gmailToken,
      this.twitterToken,
      this.isEmailVerify,
      this.isPhoneVerify,
      this.isDeleted,
      this.preferredAlertTime,
      this.createdDateTime,
      this.modifiedDateTime});

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      name: doc['name'],
      email: doc['email'],
      phoneNumber: doc['phoneNumber'],
      facebookToken: doc['facebookToken'],
      gmailToken: doc['gmailToken'],
      twitterToken: doc['twitterToken'],
      isEmailVerify: doc['isEmailVerify'],
      isPhoneVerify: doc['isPhoneVerify'],
      isDeleted: doc['isDeleted'],
      preferredAlertTime: doc['preferredAlertTime'],
      createdDateTime:
          DateTime.fromMillisecondsSinceEpoch(doc['createdDatetime']),
      modifiedDateTime:
          DateTime.fromMillisecondsSinceEpoch(doc['modifyDatetime']),
    );
  }
}
