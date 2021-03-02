import 'dart:ui';

import 'package:expiry_reminder/models/personalProductModel.dart';
import 'package:expiry_reminder/models/shoppingListModel.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/services/shoppingListService.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:expiry_reminder/widgets/MyDrawer.dart';
import 'package:expiry_reminder/widgets/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'shoppingListAction.dart';

class ViewShoppingList extends StatefulWidget {
  @override
  _ViewShoppingListState createState() => _ViewShoppingListState();
}

class _ViewShoppingListState extends State<ViewShoppingList> {
  dynamic _currentUserId;
  dynamic _shoppingList;
  dynamic _products;

  @override
  void initState() {
    super.initState();
    _setupShoppingList();
  }

  _setupShoppingList() async {
    await ShoppingListService.prepareShoppingList(
        UserAuthService.getCurrentUser().uid);
    List<PersonalProduct> products =
        await ProductService.getProducts(UserAuthService.getCurrentUser().uid);
    if (mounted) {
      setState(() {
        _currentUserId = UserAuthService.getCurrentUser().uid;
        _shoppingList = ShoppingListService.getShoppingList(_currentUserId);
        _products = products;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Shopping List'),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: IconButton(
                  icon: Icon(Icons.add, size: 28.0),
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Theme.of(context).backgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        enableDrag: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              child: Wrap(children: [
                            ShoppingListAction(currentUserId: _currentUserId)
                          ]));
                        }).then((value) => _setupShoppingList());
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         ShoppingListAction(currentUserId: _currentUserId),
                    //   ),
                    // ).then((value) => _setupShoppingList());
                  },
                )),
          ],
        ),
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Dashboard(
                        product: _products,
                      )),
                  Expanded(
                    flex: 10,
                    child: RefreshIndicator(
                      onRefresh: () => _setupShoppingList(),
                      child: FutureBuilder(
                          future: _shoppingList,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            if ((snapshot.data.length ?? 0) <= 0) {
                              return Center(
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      child: Column(children: [
                                        Text(
                                          'Empty Shopping List',
                                          style: Theme.of(context)
                                              .accentTextTheme
                                              .bodyText1,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10)),
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Click \'',
                                                  style: Theme.of(context)
                                                      .accentTextTheme
                                                      .bodyText2),
                                              Icon(Icons.add,
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              Text('\' to add some item.',
                                                  style: Theme.of(context)
                                                      .accentTextTheme
                                                      .bodyText2)
                                            ])
                                      ])));
                            }
                            List<ShoppingList> shoppingList = snapshot.data;
                            return ListView.builder(
                                itemCount: shoppingList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  ShoppingList shoppingListItem =
                                      shoppingList[index];
                                  return Dismissible(
                                    key: Key(shoppingListItem.productName),
                                    onDismissed: (direction) async {
                                      await ShoppingListService
                                              .deleteShoppingList(
                                                  _currentUserId,
                                                  shoppingListItem.id)
                                          .then((value) {
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text("Item removed")));
                                        setState(() {
                                          shoppingList.removeAt(index);
                                        });
                                      });
                                    },
                                    dismissThresholds: {
                                      DismissDirection.horizontal: 0.8
                                    },
                                    child: Card(
                                        child: ListTile(
                                      dense: false,
                                      title: Text(shoppingListItem.productName,
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .headline6),
                                      subtitle:
                                          Text(shoppingListItem.description),
                                      trailing: shoppingListItem.stock == null
                                          ? Text('Stock Left: -')
                                          : Text(
                                              'Stock Left: ${shoppingListItem.stock}'),
                                      leading: shoppingListItem.isDone
                                          ? Icon(Icons.check_box_outlined,
                                              color: safe)
                                          : Icon(Icons
                                              .check_box_outline_blank_outlined),
                                      onTap: () async {
                                        if (shoppingListItem.isDone) {
                                          await ShoppingListService.setDone(
                                                  _currentUserId,
                                                  shoppingListItem.id,
                                                  false)
                                              .then((value) {
                                            setState(() {
                                              shoppingList[index].isDone =
                                                  false;
                                            });
                                          });
                                        } else {
                                          await ShoppingListService.setDone(
                                                  _currentUserId,
                                                  shoppingListItem.id,
                                                  true)
                                              .then((value) {
                                            setState(() {
                                              shoppingList[index].isDone = true;
                                            });
                                          });
                                        }
                                      },
                                      onLongPress: () {
                                        showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Theme.of(context)
                                                .backgroundColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20))),
                                            builder: (BuildContext context) {
                                              return Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 3)),
                                                      // Text(
                                                      //   'Edit Product Photo',
                                                      //   style: Theme.of(context).primaryTextTheme.bodyText1,
                                                      // ),
                                                      // Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                                                      // Divider(),
                                                      ListTile(
                                                        title: Center(
                                                            child: Text('Edit',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor))),
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);
                                                          showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              backgroundColor: Theme
                                                                      .of(
                                                                          context)
                                                                  .backgroundColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              20),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20))),
                                                              enableDrag: true,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Container(
                                                                    child: Wrap(
                                                                        children: [
                                                                      ShoppingListAction(
                                                                          currentUserId:
                                                                              _currentUserId,
                                                                          isEdit:
                                                                              true,
                                                                          shoppingListItem:
                                                                              shoppingListItem)
                                                                    ]));
                                                              }).then((value) => _setupShoppingList());
                                                        },
                                                      ),
                                                      ListTile(
                                                        title: Center(
                                                            child: Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor))),
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);

                                                          await ShoppingListService
                                                                  .deleteShoppingList(
                                                                      _currentUserId,
                                                                      shoppingListItem
                                                                          .id)
                                                              .then((value) {
                                                            setState(() {
                                                              shoppingList
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          });
                                                        },
                                                      ),

                                                      Divider(
                                                        height: 0.5,
                                                      ),
                                                      ListTile(
                                                        title: Center(
                                                            child: Text(
                                                                'CANCEL',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor))),
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                            });
                                      },
                                    )),
                                  );
                                });
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        drawer: MyDrawer(isShoppingList: true));
  }
}
