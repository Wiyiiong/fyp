import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_reminder/models/personalProductModel.dart';
import 'package:expiry_reminder/models/shoppingListModel.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/utils/constants.dart';

class ShoppingListService {
  // get all shopping list item
  static Future<List<ShoppingList>> getShoppingList(String userId) async {
    QuerySnapshot shoppingListSnapshot =
        await userRef.doc(userId).collection('shoppingList').get();
    List<ShoppingList> shoppingList = shoppingListSnapshot.docs
        .map((doc) => ShoppingList.fromDoc(doc))
        .toList();
    shoppingList.sort((a, b) => a.createdDateTime.compareTo(b.createdDateTime));

    for (int i = 0; i < shoppingList.length; i++) {
      if (shoppingList[i].productId != null) {
        DocumentSnapshot productSnapshot = await userRef
            .doc(userId)
            .collection('personalProducts')
            .doc(shoppingList[i].productId)
            .get();
        if (productSnapshot.exists) {
          var product = productSnapshot.data();
          shoppingList[i].stock = product['numStocks'] ?? null;
        }
      }
    }
    return shoppingList;
  }

  // add new shopping list item
  static Future addShoppingList(
      String userId, ShoppingList shoppingList) async {
    try {
      await userRef.doc(userId).collection('shoppingList').add({
        'productName': shoppingList.productName,
        'description': shoppingList.description,
        'isDone': false,
        'productId': null,
        'createdDateTime': shoppingList.createdDateTime.toString(),
      });
    } catch (e) {
      print(e.message);
    }
  }

  // edit shopping list item
  static Future editShoppingList(String userId, String shoppingListId,
      ShoppingList newShoppingList) async {
    try {
      await userRef
          .doc(userId)
          .collection('shoppingList')
          .doc(shoppingListId)
          .update({
        'productName': newShoppingList.productName,
        'productId': newShoppingList.productId,
        'description': newShoppingList.description,
        'isDone': newShoppingList.isDone,
        'createdDateTime': newShoppingList.createdDateTime.toString(),
      }).catchError((e) => print(e.message));
    } catch (e) {
      print(e.message);
    }
  }

  // delete shopping list item
  static Future deleteShoppingList(String userId, String shoppingListId) async {
    try {
      var shoppingListItemSnapshot = await userRef
          .doc(userId)
          .collection('shoppingList')
          .doc(shoppingListId)
          .get();
      var shoppingListItem = shoppingListItemSnapshot.data();
      if (shoppingListItem['productId'] != null) {
        await ProductService.permanentDeleteProduct(
            userId, shoppingListItem['productId']);
      }
      await userRef
          .doc(userId)
          .collection('shoppingList')
          .doc(shoppingListId)
          .delete()
          .catchError((e) => print(e.message));
    } catch (e) {
      print(e.message);
    }
  }

  // Set the shopping list item as done or undone
  static Future setDone(
      String userId, String shoppingListId, bool isDone) async {
    try {
      await userRef
          .doc(userId)
          .collection('shoppingList')
          .doc(shoppingListId)
          .update({'isDone': isDone}).catchError((e) => print(e.message));
    } catch (e) {
      print(e.message);
    }
  }

  // static removeDoneProduct(String userId, String shoppingListId) async {
  //   try {
  //     DocumentSnapshot shoppingListSnapshot = await userRef
  //         .doc(userId)
  //         .collection('shoppingList')
  //         .doc(shoppingListId)
  //         .get();

  //     if (shoppingListSnapshot.exists) {
  //       var shoppingListItem = shoppingListSnapshot.data();
  //       if (shoppingListItem['productId'] != null &&
  //           shoppingListItem['isDone']) {
  //         await userRef
  //             .doc(userId)
  //             .collection('personalProducts')
  //             .doc(shoppingListItem['productId'])
  //             .delete()
  //             .catchError((e) => print(e.message));
  //       }
  //     }
  //   } catch (e) {
  //     print(e.message);
  //   }
  // }

  // add expired and out-of-stock product into shopping list
  static Future prepareShoppingList(String userId) async {
    List<PersonalProduct> productList =
        await ProductService.getAllProducts(userId);
    List<ShoppingList> shoppingList = await getShoppingList(userId);
    for (PersonalProduct product in productList) {
      if (product.numStocks == 0 ||
          product.expiryDate.difference(DateTime.now()).inDays <= 1) {
        if (!shoppingList.any((element) => element.productId != null)) {
          if (shoppingList.any((element) => element.productId == product.id)) {
            await userRef
                .doc(userId)
                .collection('shoppingList')
                .doc(shoppingList
                    .where((element) => element.productId == product.id)
                    .first
                    .id)
                .update({
              'productName': product.productName,
            });
          } else {
            await userRef.doc(userId).collection('shoppingList').add({
              'productName': product.productName,
              'description': '${product.productName} Qty: 1',
              'isDone': false,
              'productId': product.id,
              'createdDateTime': DateTime.now().toString(),
            });
          }
        }
      }
    }
  }
}
