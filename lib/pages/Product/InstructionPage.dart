import 'package:flutter/material.dart';

class InstructionPage extends StatefulWidget {
  @override
  _InstructionPageState createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  PageController pageViewController = new PageController();

  Widget _page1() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/instruction.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                ),
                Text("Get the Expiry Date Hassle-Free",
                    style: Theme.of(context).primaryTextTheme.headline5),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Next')),
              textColor: Theme.of(context).primaryColor,
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                pageViewController.animateToPage(1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
            ),
          )
        ],
      ),
    );
  }

  /// Page 2 - Alert and Notification
  Widget _page2() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/instruction.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                ),
                Text("1. Take a photo of the expiry date.",
                    style: Theme.of(context).primaryTextTheme.headline5),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      spacing: 15.0,
                      children: [
                        Icon(Icons.lightbulb,
                            color: Colors.yellow[700], size: 18),
                        Text("Tips:",
                            style:
                                Theme.of(context).primaryTextTheme.bodyText1),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Text("Make sure the image is clear and aligned nicely.",
                    style: Theme.of(context).primaryTextTheme.bodyText1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Next')),
              textColor: Theme.of(context).primaryColor,
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                pageViewController.animateToPage(2,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
            ),
          )
        ],
      ),
    );
  }

  /// Page 3 - Alert and Notification
  Widget _page3() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/instruction.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                ),
                Text("2. Crop Out the Expiry Date Nicely.",
                    style: Theme.of(context).primaryTextTheme.headline5),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      spacing: 15.0,
                      children: [
                        Icon(Icons.lightbulb,
                            color: Colors.yellow[700], size: 18),
                        Text("Tips:",
                            style:
                                Theme.of(context).primaryTextTheme.bodyText1),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Text(
                  "Leave least whitespaces as possible.",
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Next')),
              textColor: Theme.of(context).primaryColor,
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                pageViewController.animateToPage(3,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
            ),
          )
        ],
      ),
    );
  }

  /// Page 4 - Alert and Notification
  Widget _page4() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/instruction2.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                ),
                Text("3. Make Sure It Is Readable",
                    style: Theme.of(context).primaryTextTheme.headline5),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      spacing: 15.0,
                      children: [
                        Icon(Icons.lightbulb,
                            color: Colors.yellow[700], size: 18),
                        Text("Tips:",
                            style:
                                Theme.of(context).primaryTextTheme.bodyText1),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Text(
                  "The image should tightly cropped, readable, without any noisy background or stain. Each alphabet and digit should be clearly readable and not slanted.",
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Next')),
              textColor: Theme.of(context).primaryColor,
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                pageViewController.animateToPage(4,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
            ),
          )
        ],
      ),
    );
  }

  /// Page 5 - Alert and Notification
  Widget _page5() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/instruction3.jpg',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Text("Not All Format are Recognisable",
                    style: Theme.of(context).primaryTextTheme.headline5),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      spacing: 15.0,
                      children: [
                        Icon(Icons.priority_high, color: Colors.red, size: 18),
                        Text("Important:",
                            style:
                                Theme.of(context).primaryTextTheme.bodyText1),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "The format accepted:",
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    String.fromCharCode(0x2022) +
                        " Date Range From 2021 to 2025",
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    String.fromCharCode(0x2022) +
                        " Format in dd-MM-yyyy, dd-MM-yy",
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    String.fromCharCode(0x2022) +
                        " Format in  yyyy-MM-dd and MMM-yyyy",
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Done')),
              textColor: Theme.of(context).primaryColor,
              color: Theme.of(context).backgroundColor,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Instruction'),
        ),
        body: PageView(
          controller: pageViewController,
          children: [_page1(), _page2(), _page3(), _page4(), _page5()],
        ));
  }
}
