import 'package:expiry_reminder/models/alertModel.dart';
import 'package:expiry_reminder/models/personalProductModel.dart';
import 'package:expiry_reminder/models/shoppingListModel.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/services/shoppingListService.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'productActionPage.dart';

class ViewProductPage extends StatefulWidget {
  final String currentUserId;
  final String currentProductId;

  ViewProductPage({this.currentUserId, this.currentProductId});

  @override
  _ViewProductPageState createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage>
    with SingleTickerProviderStateMixin {
  /// Product
  PersonalProduct _product;

  TextEditingController productNameController = new TextEditingController();
  TextEditingController barcodeController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController newCategoryController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupViewProductPage();
  }

  _setupViewProductPage() async {
    PersonalProduct product = await ProductService.getProductById(
        widget.currentUserId, widget.currentProductId);
    if (mounted) {
      setState(() {
        _product = product;
      });
    }
  }

// #region [ "Print Alert Type" ]
  String printAlertType(AlertType type) {
    switch (type.index) {
      case 0:
        return alertType_0;
        break;
      case 1:
        return alertType_1;
        break;
      case 2:
        return alertType_2;
        break;
    }
    return null;
  }
  // #endregion

  List<Widget> _buildAlerts() {
    List<Widget> alertCardList = [];
    List<Alert> alertList = _product.alerts;
    if (alertList != null) {
      for (int i = 0; i < alertList.length; i++) {
        List<int> alertIndex = alertList[i].alertIndex;
        List<Widget> alertFieldIndex = [];
        for (int j = alertIndex.length - 1; j >= 0; j--) {
          alertFieldIndex.add(Text(
              printAlertType(AlertType.values[alertIndex[j]]),
              style: Theme.of(context).primaryTextTheme.bodyText1));
        }
        alertCardList.add(Container(
            padding: EdgeInsets.all(10.0),
            child: InputDecorator(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 22.0),
                  labelText: '${alertList[i].alertName}',
                  contentPadding: EdgeInsets.all(10.0),
                ),
                child: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      /// Padding
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Alert Date:'),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0)),
                                Text(
                                    DateFormat('dd/MM/yyyy (EEEE)').format(
                                      alertList[i].alertDatetime,
                                    ),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Alert Time:'),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0)),
                                Text(
                                    DateFormat('hh:mm a').format(
                                      alertList[i].alertDatetime,
                                    ),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alert Type:'),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0)),
                                Container(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: alertFieldIndex),
                                )
                              ],
                            ),
                          ]))
                    ])))));
      }
      return alertCardList;
    }
    return [
      Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
          child: Column(children: [
            Icon(Icons.notifications_off_outlined,
                color: Theme.of(context).disabledColor),
            Text('No Reminder Set',
                style: TextStyle(color: Theme.of(context).disabledColor))
          ]),
        ),
      )
    ];
  }

  Widget _buildViewProductList() {
    if (_product == null) {
      return Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              /// Insert product image
              Container(
                child: InkWell(
                  child: _product.image == null
                      ? SizedBox.shrink()
                      : Container(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 10),
                          width: MediaQuery.of(context).size.width - 40,
                          height: MediaQuery.of(context).size.height * 0.3 - 20,
                          child: Image.network(
                            _product.image,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                  splashColor: Colors.transparent,
                  onTap: () {},
                ),
              ),

              /// Padding
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),

              /// Product Information
              InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Product Information',
                    labelStyle: Theme.of(context).primaryTextTheme.headline6,
                    contentPadding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
                  ),
                  child: Column(children: [
                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),

                    /// Product Name
                    InputDecorator(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22.0),
                          labelText: 'Product Name',
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          '${_product.productName}',
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        )),

                    /// Product Category
                    InputDecorator(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 22.0,
                          ),
                          labelText: 'Product Category',
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          '${_product.category}',
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        )),

                    /// Expiry Date
                    InputDecorator(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22.0),
                          labelText: 'Expiry Date',
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          DateFormat('dd-MM-yyyy (EEEE)')
                              .format(_product.expiryDate),
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        )),

                    /// Barcode
                    InputDecorator(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22.0),
                          labelText: 'Barcode',
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          '${_product.barcode ?? '-'}',
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        )),

                    /// Barcode
                    InputDecorator(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22.0),
                          labelText: 'Description',
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          '${_product.description ?? '-'}',
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        )),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ])),

              /// Padding
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),

              /// Stock Number
              InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Stock Number',
                    labelStyle: Theme.of(context).primaryTextTheme.headline6,
                    contentPadding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
                  ),
                  child: Column(children: [
                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),

                    /// Stock Count
                    InputDecorator(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 22.0),
                          labelText: 'Stock Count',
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        child: Text(
                          '${_product.numStocks}',
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        )),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ])),

              /// Padding
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),

              /// Reminder & Alert
              InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reminder & Alert',
                    labelStyle: Theme.of(context).primaryTextTheme.headline6,
                    contentPadding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
                  ),
                  child: Column(children: [
                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),

                    ..._buildAlerts(),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ])),

              /// Padding
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),

              Divider(
                height: 1,
              ),
              FlatButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Product'),
                            content: RichText(
                                text: TextSpan(
                                    text: 'Are you sure you want to delete ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText2
                                            .color,
                                        height: 1.2),
                                    children: <TextSpan>[
                                  TextSpan(
                                      text: '${_product.productName} ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                    text: '?',
                                  )
                                ])),
                            actions: [
                              FlatButton(
                                child: Text('CANCEL',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).disabledColor)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text('DELETE'),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierColor:
                                          Theme.of(context).splashColor,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0.0,
                                          child: Expanded(
                                            child: SizedBox.expand(
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(
                                                        valueColor:
                                                            new AlwaysStoppedAnimation<
                                                                Color>(Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                                    Text('Loading...',
                                                        style: Theme.of(context)
                                                            .primaryTextTheme
                                                            .bodyText1)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                  await ProductService.permanentDeleteProduct(
                                      widget.currentUserId,
                                      widget.currentProductId);
                                  Navigator.of(context).pop();

                                  showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierColor:
                                          Theme.of(context).splashColor,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                            child: Container(
                                          padding: EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Center(
                                                  child: Icon(
                                                      Icons.done_all_outlined,
                                                      size: 28.0,
                                                      color: Theme.of(context)
                                                          .primaryIconTheme
                                                          .color)),
                                              Text('Deleted Successfully!',
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .headline5),
                                              Text('Redirect back to Home Page',
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .bodyText2),
                                              Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20.0))
                                            ],
                                          ),
                                        ));
                                      });
                                  new Future.delayed(new Duration(seconds: 3),
                                      () {
                                    Navigator.pop(context); //pop dialog
                                    Navigator.pop(
                                        context); // pop success dialog
                                    Navigator.pop(context); // pop page
                                  });
                                },
                              )
                            ],
                          );
                        });
                  },
                  child:
                      Text('Delete Product', style: TextStyle(color: danger))),
              Divider(height: 1),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Expiry Reminder',
          ),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Center(
                    child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductActionPage(
                                  currentUserId: widget.currentUserId,
                                  isEdit: true,
                                  productId: widget.currentProductId,
                                ),
                              )).then((value) => _setupViewProductPage());
                        })))
          ],
          centerTitle: true,
        ),
        body: _buildViewProductList());
  }
}
