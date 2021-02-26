import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingList {
  final String id;
  final String productName;
  final String productId;
  final String description;
  int stock;
  bool isDone;
  final DateTime createdDateTime;

  ShoppingList({
    this.id,
    this.productName,
    this.productId,
    this.description,
    this.isDone,
    this.createdDateTime,
  });

  factory ShoppingList.fromDoc(DocumentSnapshot doc) {
    return ShoppingList(
      id: doc.id,
      productName: doc['productName'],
      productId: doc['productId'],
      description: doc['description'],
      isDone: doc['isDone'],
      createdDateTime: DateTime.parse(doc['createdDateTime']),
    );
  }
}
