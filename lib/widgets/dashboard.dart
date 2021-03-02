import 'package:expiry_reminder/models/personalProductModel.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final dynamic product;

  Dashboard({this.product});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<PersonalProduct> _products = [];
  Map _productOverview = {"expired": "-", "expiredSoon": "-", "safe": "-"};

  @override
  void initState() {
    super.initState();
    _setupDashboard();
  }

  _setupDashboard() {
    if (mounted) {
      setState(() {
        if (widget.product != null) {
          _products = widget.product;
          _productOverview = getProductOverview();
        }
      });
    }
  }

  // #region [ "Dashboard - Get Total Num of Products"]
  Map getProductOverview() {
    if (_products?.length <= 0) {
      return {"expired": "-", "expiredSoon": "-", "safe": "-"};
    }

    DateTime now = new DateTime.now();
    DateTime today = new DateTime(now.year, now.month, now.day);
    int expiredCount = 0;
    int expiredSoonCount = 0;
    int safeCount = 0;
    _products.forEach((element) {
      /// if the product is expired
      if (!element.expiryDate.isAfter(today)) {
        expiredCount++;
      }

      /// if the product is not expired and one month to expired
      if (element.expiryDate.isAfter(today)) {
        if (element.expiryDate.difference(today).inDays <= 30) {
          expiredSoonCount++;
        } else if (element.expiryDate.difference(today).inDays > 30) {
          safeCount++;
        }
      }
    });

    return {
      "expired": expiredCount.toString(),
      "expiredSoon": expiredSoonCount.toString(),
      "safe": safeCount.toString()
    };
  }
  // #endregion

  // #region [ "Widget - Dashboard" ]
  Widget _buildDashboard() {
    _setupDashboard();
    var productOverview = _productOverview;
    return Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        size: 20.0,
                        color: danger,
                      ),
                      Text(
                        'Expired',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(padding: EdgeInsets.all(5)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        productOverview['expired'],
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )
                ],
              ),
            ),
            VerticalDivider(color: Theme.of(context).dividerColor),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 20.0,
                        color: medium,
                      ),
                      Text(
                        'Expired Soon',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(padding: EdgeInsets.all(5)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        productOverview['expiredSoon'],
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )
                ],
              ),
            ),
            VerticalDivider(color: Theme.of(context).dividerColor),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.sentiment_satisfied_outlined,
                        size: 20.0,
                        color: safe,
                      ),
                      Text(
                        'Safe',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(padding: EdgeInsets.all(5)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        productOverview['safe'],
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
  // #endregion

  @override
  Widget build(BuildContext context) {
    return _buildDashboard();
  }
}
