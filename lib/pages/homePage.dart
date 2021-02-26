import 'package:expiry_reminder/models/userModel.dart';
import 'package:expiry_reminder/pages/Product/productActionPage.dart';
import 'package:expiry_reminder/services/userServices.dart';
import 'package:expiry_reminder/widgets/productList.dart';
import 'package:expiry_reminder/widgets/MyDrawer.dart';
import 'package:expiry_reminder/widgets/dashboard.dart';
import 'package:expiry_reminder/widgets/searchPage.dart';
import 'package:flutter/material.dart';
import '../models/personalProductModel.dart';
import '../services/productServices.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;

  HomePage({this.currentUserId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PersonalProduct> _products = [];
  User _userDetails = new User();

  @override
  void initState() {
    super.initState();
    _setupHomePage();
  }

  _setupHomePage() async {
    await ProductService.prepareProductList(widget.currentUserId);
    List<PersonalProduct> products =
        await ProductService.getProducts(widget.currentUserId);
    User userDetails = await UserService.getUserDetails(widget.currentUserId);
    if (mounted) {
      setState(() {
        _products = products;
        _userDetails = userDetails;
      });
    }
  }

  // #region [ "Widget - Search Bar" ]
  Widget _buildSearchBar() {
    return Container(
        child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.5 / 10,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: GestureDetector(
          onTap: () {
            showSearch(
                context: context,
                delegate: SearchBarUtils(_products, widget.currentUserId));
          },
          child: Container(
              child: Stack(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      padding: EdgeInsets.all(5.0),
                      width: MediaQuery.of(context).size.width * 0.90,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context)
                                  .accentTextTheme
                                  .bodyText1
                                  .color),
                          color: Theme.of(context).backgroundColor),
                      child: Text('Search Product',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .accentTextTheme
                                  .bodyText1
                                  .color),
                          textAlign: TextAlign.center))),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
              Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      padding: EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.search_outlined,
                          size: 25.0,
                          color: Theme.of(context).primaryIconTheme.color))),
            ],
          )),
        ),
      ),
    ));
  }

  // #endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Expiry Reminder'),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: IconButton(
                  icon: Icon(Icons.add, size: 28.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductActionPage(
                            currentUserId: widget.currentUserId),
                      ),
                    ).then((value) => _setupHomePage());
                  },
                )),
          ],
        ),
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Dashboard(product: _products),
                _buildSearchBar(),
                RefreshIndicator(
                  onRefresh: () => _setupHomePage(),
                  child: ProductList(
                    productList: _products,
                    currentUserId: widget.currentUserId,
                    setupMethod: _setupHomePage(),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: MyDrawer(isHome: true));
  }
}
