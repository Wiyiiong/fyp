import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_reminder/models/alertModel.dart';
import 'package:expiry_reminder/models/recentSearchModel.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:expiry_reminder/utils/functions.dart';
import '../models/personalProductModel.dart';
import '../utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dart:io';

class ProductService {
  /// Get all non deleted personal product of the user
  static Future<List<PersonalProduct>> getProducts(String userId) async {
    QuerySnapshot productSnapshot = await userRef
        .doc(userId)
        .collection('personalProducts')
        .where('isDeleted', isEqualTo: false)
        .get();
    List<PersonalProduct> products = productSnapshot.docs
        .map((doc) => PersonalProduct.fromDoc(doc))
        .toList();
    products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return products;
  }

  /// Get all personal product of the user
  static Future<List<PersonalProduct>> getAllProducts(String userId) async {
    QuerySnapshot productSnapshot =
        await userRef.doc(userId).collection('personalProducts').get();
    List<PersonalProduct> products = productSnapshot.docs
        .map((doc) => PersonalProduct.fromDoc(doc))
        .toList();
    products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return products;
  }

  /// Get a list of product based on category
  static Future<List<PersonalProduct>> getProductsByCategory(
      String userId, String category) async {
    QuerySnapshot productSnapshot = await userRef
        .doc(userId)
        .collection('personalProducts')
        .where('category', isEqualTo: category)
        .where('isDeleted', isEqualTo: false)
        .get();
    if (productSnapshot.docs.length > 0) {
      List<PersonalProduct> products = productSnapshot.docs
          .map((doc) => PersonalProduct.fromDoc(doc))
          .toList();
      products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      return products;
    }
    return new List<PersonalProduct>();
  }

  /// Get a single product based on the id
  static Future<PersonalProduct> getProductById(
      String userId, String productId) async {
    DocumentSnapshot productSnapshot = await userRef
        .doc(userId)
        .collection('personalProducts')
        .doc(productId)
        .get();
    PersonalProduct product = PersonalProduct.fromDoc(productSnapshot);
    product.alerts = await getAlerts(userId, productId);
    return product.isDeleted ? null : product;
  }

  /// Get a single product based on the id
  static Future<PersonalProduct> getProductByBarcode(
      String userId, String barcode) async {
    QuerySnapshot productSnapshot = await userRef
        .doc(userId)
        .collection('personalProducts')
        .where('barcode', isEqualTo: barcode)
        .where('isDeleted', isEqualTo: false)
        .get();
    if (productSnapshot.docs.length > 0) {
      List<PersonalProduct> products = productSnapshot.docs
          .map((doc) => PersonalProduct.fromDoc(doc))
          .toList();
      var product = products.first;
      return product;
    }
    return null;
  }

  /// Get all alert of the product
  static Future<List<Alert>> getAlerts(String userId, String productId) async {
    QuerySnapshot alertSnapshot = await userRef
        .doc(userId)
        .collection('personalProducts')
        .doc(productId)
        .collection('alert')
        .get();
    if (alertSnapshot.docs.length > 0) {
      List<Alert> alerts =
          alertSnapshot.docs.map((doc) => Alert.fromDoc(doc)).toList();
      alerts.sort((a, b) => a.alertDatetime.compareTo(b.alertDatetime));
      return alerts;
    }
    return null;
  }

  /// Get all category added by the user
  static Future<List<String>> getCategory(String userId) async {
    QuerySnapshot productSnapshot = await userRef
        .doc(userId)
        .collection('personalProducts')
        .where('isDeleted', isEqualTo: false)
        .get();

    List<dynamic> categories = productSnapshot.docs
        .map((doc) => PersonalProduct.fromDoc(doc))
        .toList()
        .map((e) => e.category)
        .toList();
    QuerySnapshot categorySnapshot =
        await userRef.doc(userId).collection('unuseCategory').get();
    List<dynamic> unuseCategories =
        categorySnapshot.docs.map((doc) => doc['categoryName']).toList();

    if (categories != null) {
      // remove duplicates in the category
      List<dynamic> categoryList = (categories
              .fold<Map<String, int>>(
                  <String, int>{},
                  (map, letter) => map
                    ..update(letter, (value) => value + 1, ifAbsent: () => 1))
              .entries
              .toList()
                ..sort((e1, e2) => e2.value.compareTo(e1.value)))
          .map((e) => e.key)
          .toList();

      if (unuseCategories != null) {
        for (int i = 0; i < unuseCategories.length; i++) {
          categoryList.add(unuseCategories[i]);
        }
      }
      if (!categoryList.contains("None")) {
        categoryList.add("None");
      }
      categoryList.sort((e1, e2) => e1.compareTo(e2));
      categoryList.remove("None");
      categoryList.add("None");
      print(categoryList);
      return categoryList;
    }

    return null;
  }

  /// Get recent search history
  static Future<List<String>> getRecentLists(String userId) async {
    QuerySnapshot recentListSnapshot =
        await userRef.doc(userId).collection('recentSearchProduct').get();
    List<RecentSearch> recentLists = recentListSnapshot.docs
        .map((doc) => RecentSearch.fromDoc(doc))
        .toList();

    /// take the first 3 of the latest search history
    if (recentLists?.length > 3) {
      recentLists.sort((a, b) => b.searchDatetime.compareTo(a.searchDatetime));
      recentLists.removeRange(2, recentLists.length - 1);
    }

    /// Sort the list with the occurence
    recentLists.sort((a, b) => b.occurrences.compareTo(a.occurrences));
    print(recentLists);
    List<String> recentListsStrings = recentLists
        .map((element) => UtilFunctions.capitalizeWord(element.searchString))
        .toList();
    return recentListsStrings;
  }

  /// Add recent search history
  static Future addRecentSearch(String userId, String searchString) async {
    QuerySnapshot recentListSnapshot = await userRef
        .doc(userId)
        .collection('recentSearchProduct')
        .where('searchString', isEqualTo: searchString.toLowerCase().trim())
        .get();

    if (recentListSnapshot.docs.length > 0) {
      int occurrences = recentListSnapshot.docs.first.get('occurrences');
      await userRef
          .doc(userId)
          .collection('recentSearchProduct')
          .doc(recentListSnapshot.docs.first.id)
          .set({
        'occurrences': (occurrences + 1),
        'searchDatetime': DateTime.now().toString(),
      }, SetOptions(merge: true));
    } else {
      await userRef.doc(userId).collection('recentSearchProduct').add({
        'occurrences': 1,
        'searchDatetime': DateTime.now().toString(),
        'searchString': searchString.toLowerCase().trim()
      });
    }
  }

  /// Add new personal products
  static Future<bool> addNewPersonalProduct(
      PersonalProduct product, String userId) async {
    try {
      DocumentReference docRef =
          await userRef.doc(userId).collection('personalProducts').add({
        'barcode': product.barcode,
        'category': product.category,
        'description': product.description,
        'expiryDate': product.expiryDate.toString(),
        'image': product.image,
        'numStocks': product.numStocks,
        'productName': product.productName,
        'isDeleted': false,
      });

      if (docRef != null) {
        for (int i = 0; i < product.alerts.length; i++) {
          await userRef
              .doc(userId)
              .collection('personalProducts')
              .doc(docRef.id)
              .collection('alert')
              .add({
            'alertDatetime':
                Timestamp.fromDate(product.alerts[i].alertDatetime),
            'alertName': product.alerts[i].alertName,
            'alertType': product.alerts[i].alertIndex,
            'isAlert': false,
          });
        }

        return true;
      }
    } catch (e) {
      print(e.message);
    }
    return false;
  }

  /// Edit personal products
  static Future editPersonalProduct(
      PersonalProduct product, String userId) async {
    try {
      await userRef
          .doc(userId)
          .collection('personalProducts')
          .doc(product.id)
          .set({
        'barcode': product.barcode,
        'category': product.category,
        'description': product.description,
        'expiryDate': product.expiryDate.toString(),
        'image': product.image,
        'numStocks': product.numStocks,
        'productName': product.productName,
      }, SetOptions(merge: true));

      DocumentSnapshot productSnapshot = await userRef
          .doc(userId)
          .collection('personalProducts')
          .doc(product.id)
          .get();

      if (productSnapshot.exists) {
        productSnapshot.reference
            .collection('alert')
            .get()
            .then((alertSnapshot) async {
          for (DocumentSnapshot alertds in alertSnapshot.docs) {
            await alertds.reference
                .delete()
                .catchError((e) => print(e.message));
          }
        }).then((value) async {
          for (int i = 0; i < product.alerts.length; i++) {
            await userRef
                .doc(userId)
                .collection('personalProducts')
                .doc(product.id)
                .collection('alert')
                .add({
              'alertDatetime':
                  Timestamp.fromDate(product.alerts[i].alertDatetime),
              'alertName': product.alerts[i].alertName,
              'alertType': product.alerts[i].alertIndex,
              'isAlert': false
            });
          }
        });
      }

      return true;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  // Remove Out-ofstock product from the list
  static Future deletePersonalProduct(String userId, String productId) async {
    try {
      DocumentSnapshot productSnapshot = await userRef
          .doc(userId)
          .collection('personalProducts')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        productSnapshot.reference
            .collection('alert')
            .get()
            .then((alertSnapshot) async {
          for (DocumentSnapshot alertds in alertSnapshot.docs) {
            await alertds.reference
                .delete()
                .catchError((e) => print(e.message));
          }
        });
        await productSnapshot.reference
            .update({'isDeleted': true}).catchError((e) => print(e.message));
      }
    } catch (e) {
      print(e.message);
    }
  }

  // Permanently delete a product
  static Future permanentDeleteProduct(String userId, String productId) async {
    try {
      DocumentSnapshot productSnapshot = await userRef
          .doc(userId)
          .collection('personalProducts')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        productSnapshot.reference
            .collection('alert')
            .get()
            .then((alertSnapshot) async {
          for (DocumentSnapshot alertds in alertSnapshot.docs) {
            await alertds.reference
                .delete()
                .catchError((e) => print(e.message));
          }
        });
        await productSnapshot.reference
            .delete()
            .catchError((e) => print(e.message));
      }
    } catch (e) {
      print(e.message);
    }
  }

  /// Add new personal category
  static Future addNewCategory(String category, String userId) async {
    try {
      await userRef.doc(userId).collection('unuseCategory').add({
        'categoryName': category,
      });
    } catch (e) {
      print(e.message);
    }
  }

  /// Remove unused category if the category is used
  static Future removeUnuseCategory(String category, String userId) async {
    try {
      QuerySnapshot snapshot = await userRef
          .doc(userId)
          .collection('unuseCategory')
          .where('categoryName', isEqualTo: category)
          .get();
      if (snapshot.docs.length > 0) {
        await userRef
            .doc(userId)
            .collection('unuseCategory')
            .doc(snapshot.docs.first.id)
            .delete()
            .catchError((e) => print(e.message));
      }
    } catch (e) {
      print(e.message);
    }
  }

  /// Edit Existing Category
  static Future editCategory(
      String category, String newCategory, String userId) async {
    try {
      // search in unused category
      QuerySnapshot unusedCategorySnapshot = await userRef
          .doc(userId)
          .collection('unuseCategory')
          .where('categoryName', isEqualTo: category)
          .get();
      if (unusedCategorySnapshot.docs.length > 0) {
        await userRef
            .doc(userId)
            .collection('unuseCategory')
            .doc(unusedCategorySnapshot.docs.first.id)
            .update({'categoryName': newCategory}).catchError(
                (e) => print(e.message));
      }
      // search in all products
      QuerySnapshot usedCategorySnapshot = await userRef
          .doc(userId)
          .collection('personalProducts')
          .where('category', isEqualTo: category)
          .get();
      if (usedCategorySnapshot.docs.length > 0) {
        for (DocumentSnapshot ds in usedCategorySnapshot.docs) {
          DocumentSnapshot product = await userRef
              .doc(userId)
              .collection('personalProducts')
              .doc(ds.id)
              .get();
          await product.reference.update({'category': newCategory}).catchError(
              (e) => print(e.message));
        }
      }
    } catch (e) {
      print(e.message);
    }
  }

  /// Delete Category and its product
  static Future deleteCategory(String category, String userId) async {
    try {
      // search in unused category
      QuerySnapshot unusedCategorySnapshot = await userRef
          .doc(userId)
          .collection('unuseCategory')
          .where('categoryName', isEqualTo: category)
          .get();
      if (unusedCategorySnapshot.docs.length > 0) {
        await userRef
            .doc(userId)
            .collection('unuseCategory')
            .doc(unusedCategorySnapshot.docs.first.id)
            .delete()
            .catchError((e) => print(e.message));
      }
      // search in personal product
      QuerySnapshot productSnapshot = await userRef
          .doc(userId)
          .collection('personalProducts')
          .where('category', isEqualTo: category)
          .get();
      if (productSnapshot.docs.length > 0) {
        for (DocumentSnapshot productds in productSnapshot.docs) {
          QuerySnapshot alertSnapshot = await userRef
              .doc(userId)
              .collection('personalProducts')
              .doc(productds.id)
              .collection('alert')
              .get();
          if (alertSnapshot.docs.length > 0) {
            for (DocumentSnapshot alertds in alertSnapshot.docs) {
              await userRef
                  .doc(userId)
                  .collection('personalProducts')
                  .doc(productds.id)
                  .collection('alert')
                  .doc(alertds.id)
                  .delete()
                  .catchError((e) => print(e.message));
            }
          }
          await userRef
              .doc(userId)
              .collection('personalProducts')
              .doc(productds.id)
              .update({'isDeleted': true}).catchError((e) => print(e.message));
        }
      }
    } catch (e) {
      print(e.message);
    }
  }

  /// Upload product image into cloud storage
  static Future<String> uploadProductImage(File image) async {
    String downloadUrl;
    try {
      UploadTask task = storageRef
          .child('image/user/${DateTime.now().toString()}.jpg')
          .putFile(image);
      TaskSnapshot snapshot = await task;
      downloadUrl = await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print(e.message);
    }
    return downloadUrl;
  }

  // To remove out of stock product from the list
  static Future prepareProductList(String userId) async {
    List<PersonalProduct> productList = await getProducts(userId);

    productList.forEach((e) async {
      if (e.numStocks == 0) {
        await deletePersonalProduct(userId, e.id);
      }
    });
  }
}
