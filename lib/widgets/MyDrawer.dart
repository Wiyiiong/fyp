import 'package:expiry_reminder/pages/Category/searchByCategory.dart';
import 'package:expiry_reminder/pages/Product/viewProductPage.dart';
import 'package:expiry_reminder/pages/Settings/settings.dart';
import 'package:expiry_reminder/pages/ShoppingList/shoppingList.dart';
import 'package:expiry_reminder/pages/homePage.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'ErrorDialog.dart';

class MyDrawer extends StatefulWidget {
  final bool isHome;
  final bool isCategory;
  final bool isSearchByBarcode;
  final bool isShoppingList;
  final bool isSettings;

  MyDrawer({
    this.isHome = false,
    this.isCategory = false,
    this.isSearchByBarcode = false,
    this.isShoppingList = false,
    this.isSettings = false,
  });

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  // #region [ "Barcode Scanner - barcode scanner"]
  Future scanBarcode() async {
    String barcode;
    try {
      barcode = await FlutterBarcodeScanner.scanBarcode(
          '#00ff55', "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcode = 'Failed to get platform version.';
    }

    if (barcode != null || barcode != "" || barcode != '-1') {
      return barcode;
    }
    return null;
  }

  // #endregion
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
      // Drawer Heading
      Container(
        height: MediaQuery.of(context).size.height * 0.12,
        width: MediaQuery.of(context).size.width,
        child: DrawerHeader(
          child: Text('Expiry Reminder',
              style: Theme.of(context).primaryTextTheme.headline6),
        ),
      ),
      Expanded(
        child: ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: <
            Widget>[
          // Home
          ListTile(
              title: Text(
                'Home',
                style: widget.isHome
                    ? TextStyle(color: Theme.of(context).primaryColor)
                    : TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color),
              ),
              leading: Icon(Icons.home_outlined,
                  color: widget.isHome
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryTextTheme.bodyText1.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      currentUserId: UserAuthService.getCurrentUser().uid,
                    ),
                  ),
                );
              }),
          // Category
          ListTile(
              title: Text(
                'Category',
                style: widget.isCategory
                    ? TextStyle(color: Theme.of(context).primaryColor)
                    : TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color),
              ),
              leading: Icon(Icons.category_outlined,
                  color: widget.isCategory
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryTextTheme.bodyText1.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchByCategory(),
                  ),
                );
              }),
          // Search By Barcode
          ListTile(
              title: Text(
                'Search By Barcode',
                style: widget.isSearchByBarcode
                    ? TextStyle(color: Theme.of(context).primaryColor)
                    : TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color),
              ),
              leading: Icon(Icons.qr_code_scanner_outlined,
                  color: widget.isSearchByBarcode
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryTextTheme.bodyText1.color),
              onTap: () async {
                String barcode = await scanBarcode();
                if (barcode == null || barcode == '-1') {
                  showDialog(
                      context: context,
                      builder: (_) => ErrorDialog(
                          errorTitle: "Barcode Not Found",
                          errorMessage:
                              "No product is found with the barcode. Please try again."));
                } else {
                  var product = await ProductService.getProductByBarcode(
                      UserAuthService.getCurrentUser().uid, barcode);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewProductPage(
                            currentProductId: product.id,
                            currentUserId:
                                UserAuthService.getCurrentUser().uid),
                      ));
                }
              }),
          // Shopping List
          ListTile(
              title: Text(
                'Shopping List',
                style: widget.isShoppingList
                    ? TextStyle(color: Theme.of(context).primaryColor)
                    : TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color),
              ),
              leading: Icon(Icons.list_alt_outlined,
                  color: widget.isShoppingList
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryTextTheme.bodyText1.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewShoppingList(),
                  ),
                );
              }),
          // Settings
          ListTile(
              title: Text(
                'Settings',
                style: widget.isSettings
                    ? TextStyle(color: Theme.of(context).primaryColor)
                    : TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color),
              ),
              leading: Icon(Icons.settings_outlined,
                  color: widget.isSettings
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryTextTheme.bodyText1.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings(),
                  ),
                );
              }),
        ]),
      ),

      Padding(
          padding: EdgeInsets.all(10),
          child:
              Text('WiYi Final Year Project', style: TextStyle(fontSize: 10))),
    ]));
  }
}
