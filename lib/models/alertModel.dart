import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType {
  notification, // 0
  sms, // 1
  email, // 2
}

class Alert {
  final String id;
  final List<int> alertIndex;
  final String alertName;
  // final AlertType alertType;
  final DateTime alertDatetime;

  Alert({
    this.id = "",
    this.alertIndex,
    this.alertName,
    this.alertDatetime,
  });

  AlertType getAlertType(int alertIndex) {
    return AlertType.values[alertIndex];
  }

  factory Alert.fromDoc(DocumentSnapshot doc) {
    return Alert(
      id: doc.id,
      alertName: doc['alertName'],
      alertDatetime: doc['alertDatetime'].toDate(),
      alertIndex: List.castFrom(doc['alertType']),
    );
  }
}
