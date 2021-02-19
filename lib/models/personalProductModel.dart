import 'package:cloud_firestore/cloud_firestore.dart';

import 'alertModel.dart';

class PersonalProduct {
  final String id;
  final String image;
  final String productName;
  final String description;
  final String barcode;
  final int numStocks;
  final DateTime expiryDate;
  final String category;
  List<Alert> alerts;

  PersonalProduct({
    this.id,
    this.image,
    this.productName,
    this.description,
    this.barcode,
    this.numStocks,
    this.expiryDate,
    this.category,
  });

  factory PersonalProduct.fromDoc(DocumentSnapshot doc) {
    return PersonalProduct(
      id: doc.id,
      image: doc['image'],
      productName: doc['productName'],
      description: doc['description'],
      barcode: doc['barcode'],
      numStocks: doc['numStocks'],
      expiryDate: DateTime.parse(doc['expiryDate']),
      category: doc['category'],
    );
  }
}
