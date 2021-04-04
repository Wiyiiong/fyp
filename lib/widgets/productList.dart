import 'package:expiry_reminder/pages/Product/viewProductPage.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../utils/ThemeData.dart';

class ProductList extends StatefulWidget {
  final dynamic productList;
  final dynamic currentUserId;
  final dynamic setupMethod;
  ProductList(
      {@required this.productList,
      @required this.currentUserId,
      this.setupMethod});
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
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

  // #region [ "Widget - Product List View" ]
  Widget _buildProductList() {
    final products = widget.productList;
    return Row(
      children: [
        Expanded(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    Map details = getChartDetails('${products[i].expiryDate}');
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProductPage(
                              currentUserId: widget.currentUserId,
                              currentProductId: products[i].id,
                            ),
                          ),
                        ).then((value) => widget.setupMethod);
                      },
                      onLongPress: () async {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Product'),
                                content: RichText(
                                    text: TextSpan(
                                        text:
                                            'Are you sure you want to delete ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .primaryTextTheme
                                                .bodyText2
                                                .color,
                                            height: 1.2),
                                        children: <TextSpan>[
                                      TextSpan(
                                          text: '${products[i].productName} ',
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
                                            color: Theme.of(context)
                                                .disabledColor)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('DELETE'),
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          barrierColor:
                                              Theme.of(context).splashColor,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0.0,
                                              child: Expanded(
                                                child: SizedBox.expand(
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CircularProgressIndicator(
                                                            valueColor: new AlwaysStoppedAnimation<
                                                                Color>(Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                                        Text('Loading...',
                                                            style: Theme.of(
                                                                    context)
                                                                .primaryTextTheme
                                                                .bodyText1)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                      await ProductService
                                          .permanentDeleteProduct(
                                              widget.currentUserId,
                                              products[i].id);
                                      Navigator.of(context).pop();
                                      products.removeAt(i);
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
                                                          Icons
                                                              .done_all_outlined,
                                                          size: 28.0,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryIconTheme
                                                              .color)),
                                                  Text('Deleted Successfully!',
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .headline5),
                                                  Text(
                                                      'Redirect back to Home Page',
                                                      style: Theme.of(context)
                                                          .primaryTextTheme
                                                          .bodyText2),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 20.0))
                                                ],
                                              ),
                                            ));
                                          });
                                      new Future.delayed(
                                          new Duration(seconds: 3), () {
                                        Navigator.pop(context); //pop dialog
                                        Navigator.pop(
                                            context); // pop success dialog
                                      });
                                    },
                                  )
                                ],
                              );
                            });
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
                                  circularStrokeCap: CircularStrokeCap.square,
                                  progressColor: details['Color'],
                                  backgroundColor: Colors.transparent,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 3),
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
    );
  }

  // #endregion
  @override
  Widget build(BuildContext context) {
    return _buildProductList();
  }
}
