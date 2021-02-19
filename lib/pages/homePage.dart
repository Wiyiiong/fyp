import 'package:expiry_reminder/models/userModel.dart';
import 'package:expiry_reminder/pages/Product/addProductPage.dart';
import 'package:expiry_reminder/services/userServices.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:expiry_reminder/widgets/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../models/personalProductModel.dart';
import '../services/productServices.dart';
import 'Product/viewProductPage.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;

  HomePage({this.currentUserId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PersonalProduct> _products = [];
  User _userDetails = new User();
  Map _productOverview = {"expired": "-", "expiredSoon": "-", "safe": "-"};

  @override
  void initState() {
    super.initState();
    _setupHomePage();
  }

  _setupHomePage() async {
    List<PersonalProduct> products =
        await ProductService.getProducts(widget.currentUserId);
    User userDetails = await UserService.getUserDetails(widget.currentUserId);
    if (mounted) {
      setState(() {
        _products = products;
        _userDetails = userDetails;
        if (products != null) {
          _productOverview = getProductOverview();
        }
      });
    }
  }

  // #region [ "Product List - Get Chart Details" ]
  // get chart details according to expiry date
  Map getChartDetails(String date) {
    // get product date and todays date
    DateTime d = new DateFormat("yyyy-MM-dd").parse(date);
    DateTime now = new DateTime.now();
    DateTime today = new DateTime(now.year, now.month, now.day);

    // declare variables
    Color color = Colors.black;
    int day = 0;
    double percentage = 0.0;
    String status1 = "";
    String status2 = "";

    /// if product date is not expired
    ///     calculate the date
    ///     set indicator color accordingly
    ///     set status message accordingly
    /// else product date is expired
    ///     set the indicator to 1.0
    ///     set the indicator color to red
    ///     set status message to "Expired"
    ///
    if (d.isAfter(today)) {
      day = d.difference(today).inDays;

      /// print product status
      print("No expired");
      print("Date interval: $day days");

      /// set chart color to green
      color = safe;

      /// if there are plenty of days
      ///     set the indicator to 100%
      ///     get the date difference in months
      ///  else
      ///     set the indicator according to the date
      ///
      if (day > 100) {
        percentage = 1.0;
        var month = day / 30;

        /// if there are more than one year
        ///     display date interval in year
        /// else
        ///     display date interval in month
        ////
        if (month.ceil() > 12) {
          var year = month ~/ 12;
          status1 = "$year";
          status2 = "years";
        } else {
          // display
          var newMonth = month.ceil();
          status1 = "$newMonth";
          status2 = "months";
        }
      } else {
        percentage = (100 - day) / 100;

        /// if there is more than one month
        ///      set indicator to green
        ///      display date interval in months
        /// else if there is one month before expired
        ///      set indicator to yellow
        ///      display date interval in days
        /// else there is less than 2 weeks
        ///      set indicator to red
        ///      display date interval in days
        ///
        if (day > 30) {
          color = safe;
          var month = day ~/ 30;
          status1 = "$month";
          status2 = "months";
        } else if (14 <= day && day <= 30) {
          color = medium;
          status1 = "$day";
          status2 = "days";
        } else if (day < 14) {
          color = closeToDanger;
          status1 = "$day";
          status2 = "days";
        }
      }
    } else {
      day = today.difference(d).inDays;
      print('Expired');
      print(day);
      color = danger;
      percentage = 1.0;
      status1 = '\u{2715}';
      status2 = "Expired!";
    }

    return {
      "Day": day,
      "Percentage": percentage,
      "Color": color,
      "Date": new DateFormat("dd/MM/yyyy").format(d),
      "Status1": status1,
      "Status2": status2,
    };
  }
  // #endregion

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

  // #region [ "Widget" ]
  // #region [ "Widget - Dashboard" ]
  Widget _buildDashboard() {
    var productOverview = _productOverview;
    return Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.8 / 10,
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

  // #region [ "Widget - Product List View" ]
  Widget _buildProductList() {
    final products = _products;
    return RefreshIndicator(
        onRefresh: () => _setupHomePage(),
        child: Row(
          children: [
            Expanded(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height * 7.5 / 10,
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        Map details =
                            getChartDetails('${products[i].expiryDate}');
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProductPage(
                                  currentUserId: widget.currentUserId,
                                  currentProductId: _products[i].id,
                                ),
                              ),
                            );
                          },
                          child: Card(
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(children: [
                                    CircularPercentIndicator(
                                      radius: 70.0,
                                      lineWidth: 6.0,
                                      animation: true,
                                      percent: details['Percentage'],
                                      center: Container(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Text(
                                              details['Status1'],
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              details['Status2'],
                                              style: TextStyle(
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w500),
                                              textAlign: TextAlign.center,
                                            )
                                          ])),
                                      circularStrokeCap:
                                          CircularStrokeCap.square,
                                      progressColor: details['Color'],
                                      backgroundColor: Colors.transparent,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                    ),
                                    Container(
                                        child: Column(
                                            children: [
                                          Text(
                                            '${products[i].productName}',
                                            style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 3),
                                          ),
                                          Text(
                                            'Expiry date: ${details['Date']}',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start))
                                  ], mainAxisSize: MainAxisSize.min))),
                        );
                      },
                      scrollDirection: Axis.vertical,
                    )))
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ));
  }
  // #endregion
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
                _buildDashboard(),
                _buildSearchBar(),
                _buildProductList(),
              ],
            ),
          ),
        ));
  }
}
