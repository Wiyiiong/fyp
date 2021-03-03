import 'package:expiry_reminder/models/personalProductModel.dart';
import 'package:expiry_reminder/services/cloudMessagingServices.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/widgets/productList.dart';
import 'package:flutter/material.dart';

class ProductByCategory extends StatefulWidget {
  final dynamic category;
  final dynamic currentUserId;

  ProductByCategory({@required this.category, @required this.currentUserId});

  @override
  _ProductByCategoryState createState() => _ProductByCategoryState();
}

class _ProductByCategoryState extends State<ProductByCategory> {
  List<PersonalProduct> _productList;

  _setupProductByCategory() async {
    var productList = await ProductService.getProductsByCategory(
        UserAuthService.getCurrentUser().uid, widget.category);
    if (mounted) {
      setState(() {
        _productList = productList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupProductByCategory();
    // CloudMessagingService.getNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    // var futureBuilder = new StreamBuilder(
    //     stream: _productList.asStream(),
    //     builder: (BuildContext context, AsyncSnapshot snapshot) {
    //       if (!snapshot.hasData) {
    //         return Center(child: CircularProgressIndicator());
    //       }
    //       if (snapshot.data.length == 0) {
    //         return Center(
    //             child: Text('No Product Found',
    //                 style: Theme.of(context).accentTextTheme.bodyText1));
    //       }
    //       List<PersonalProduct> productList = snapshot.data;
    //       return ProductList(
    //         productList: productList,
    //         currentUserId: UserAuthService.getCurrentUser().uid,
    //         setupMethod: _setupProductByCategory,
    //       );
    //     });
    if (_productList == null) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(widget.category),
            // actions: <Widget>[
            //   Padding(
            //       padding: EdgeInsets.only(right: 10.0),
            //       child: IconButton(
            //         icon: Icon(Icons.add, size: 28.0),
            //         onPressed: () {},
            //       )),
            // ],
          ),
          body: Center(child: CircularProgressIndicator()));
    }

    if (_productList.length == 0) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(widget.category),
            // actions: <Widget>[
            //   Padding(
            //       padding: EdgeInsets.only(right: 10.0),
            //       child: IconButton(
            //         icon: Icon(Icons.add, size: 28.0),
            //         onPressed: () {},
            //       )),
            // ],
          ),
          body: Center(
              child: Text('No Product Found',
                  style: Theme.of(context).accentTextTheme.bodyText1)));
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.category),
          // actions: <Widget>[
          //   Padding(
          //       padding: EdgeInsets.only(right: 10.0),
          //       child: IconButton(
          //         icon: Icon(Icons.add, size: 28.0),
          //         onPressed: () {},
          //       )),
          // ],
        ),
        body: RefreshIndicator(
            onRefresh: () => _setupProductByCategory(),
            child: ProductList(
              productList: _productList,
              currentUserId: UserAuthService.getCurrentUser().uid,
              setupMethod: _setupProductByCategory(),
            )));
  }
}
