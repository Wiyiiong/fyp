import 'package:flutter/material.dart';

// Define color to be used for the app
/// b - background
Color bWhite = Colors.grey[50];

/// t - text
Color tBlack = Colors.black;
Color tGrey = Colors.grey;
Color tWhite = Colors.white;

/// tt - title
Color ttGrey = Colors.grey[800];

/// p - primary
Color pGrey = Colors.grey;
Color pOrange = Colors.orange[700];
Color pWhite = Colors.white;
Color pPurple = Colors.purple[800];

/// a - accent
Color aLightGrey = Colors.grey[500];
Color aDarkGrey = Colors.grey[800];

/// colors to indicates the danger, close to danger, safe and medium
Color danger = Colors.red;
Color safe = Colors.green[800];
Color medium = Colors.yellow[800];
Color closeToDanger = Colors.deepOrange;

// theme
ThemeData buildLightTheme() {
  final ThemeData base = ThemeData();
  return base.copyWith(
    brightness: Brightness.light,
    primaryColor: pOrange,
    accentColor: pPurple,
    scaffoldBackgroundColor: bWhite,
    dividerColor: aDarkGrey,
    disabledColor: aLightGrey,
    buttonTheme: ButtonThemeData(
      buttonColor: pOrange,
      textTheme: ButtonTextTheme.primary,
      disabledColor: aDarkGrey,
    ),
    textButtonTheme:
        TextButtonThemeData(style: TextButton.styleFrom(primary: pOrange)),
    backgroundColor: bWhite,
    appBarTheme: AppBarTheme(
      elevation: 10,
      color: bWhite,
      iconTheme: IconThemeData(color: pOrange, size: 35.0),
      centerTitle: true,
    ),
    primaryIconTheme: IconThemeData(color: pOrange, size: 35.0),
    accentIconTheme: IconThemeData(color: pGrey, size: 35.0),
    primaryTextTheme: TextTheme(
      headline1:
          TextStyle(color: ttGrey, fontSize: 45.0, fontWeight: FontWeight.bold),
      headline2:
          TextStyle(color: ttGrey, fontSize: 40.0, fontWeight: FontWeight.w700),
      headline3:
          TextStyle(color: ttGrey, fontSize: 35.0, fontWeight: FontWeight.w500),
      headline4: TextStyle(color: ttGrey, fontSize: 30.0),
      headline5: TextStyle(color: ttGrey, fontSize: 28.0),
      headline6: TextStyle(color: ttGrey, fontSize: 20.0),
      bodyText1: TextStyle(color: ttGrey, fontSize: 14.0),
      bodyText2: TextStyle(color: ttGrey),
      subtitle1: TextStyle(
          color: aDarkGrey, fontSize: 16.0, fontWeight: FontWeight.w500),
      subtitle2: TextStyle(
          color: aDarkGrey, fontSize: 14.0, fontWeight: FontWeight.w500),
      button: TextStyle(color: pOrange),
    ),
    accentTextTheme: TextTheme(
      headline1:
          TextStyle(color: tGrey, fontSize: 45.0, fontWeight: FontWeight.bold),
      headline2:
          TextStyle(color: tGrey, fontSize: 40.0, fontWeight: FontWeight.w700),
      headline3:
          TextStyle(color: tGrey, fontSize: 35.0, fontWeight: FontWeight.w500),
      headline4: TextStyle(color: tGrey, fontSize: 30.0),
      headline5: TextStyle(color: tGrey, fontSize: 28.0),
      headline6: TextStyle(color: tGrey, fontSize: 24.0),
      bodyText1: TextStyle(color: tGrey, fontSize: 20.0),
      bodyText2: TextStyle(color: tGrey, fontSize: 14.0),
      button: TextStyle(color: pWhite),
    ),
    colorScheme: ColorScheme.light(
      primary: pOrange,
      onPrimary: Colors.white,
      surface: bWhite,
      onSurface: tBlack,
    ),
    cursorColor: pOrange,
  );
}
