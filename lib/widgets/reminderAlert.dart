import 'package:expiry_reminder/models/alertModel.dart';
import 'package:expiry_reminder/models/userModel.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ReminderAlert extends StatefulWidget {
  final DateTime expiryDate;
  final Function(dynamic) onChanged;
  final User userDetails;
  final String productName;
  final String productId;
  final bool isEdit;

  ReminderAlert(
      {@required this.expiryDate,
      @required this.onChanged,
      @required this.userDetails,
      @required this.productName,
      @required this.productId,
      this.isEdit = false});

  @override
  _ReminderAlertState createState() => _ReminderAlertState();
}

class _ReminderAlertState extends State<ReminderAlert> {
  // Alert List
  List<Alert> _alertList;
  DateTime now;
  DateTime today;

  // Switch
  bool _isSwitchOn;

  List<dynamic> _selectedValue;
  List<dynamic> _selectedType;
  bool _isDoneSelected;

  @override
  void initState() {
    super.initState();
    now = new DateTime.now();
    today = new DateTime(now.year, now.month, now.day);
    _isSwitchOn = widget.isEdit;
    _isDoneSelected = false;
    _selectedValue = [];
    _selectedType = [];
    _alertList = [];
    if (widget.isEdit) {
      setUpReminderDetails();
    }
  }

  void setUpReminderDetails() async {
    List<Alert> alertList =
        await ProductService.getAlerts(widget.userDetails.id, widget.productId);
    List<dynamic> selectedValue = new List<dynamic>();
    List<dynamic> selectedType = new List<dynamic>();
    if (alertList != null) {
      for (int i = 0; i < alertList.length; i++) {
        DateTime alertDatetime = new DateTime(alertList[i].alertDatetime.year,
            alertList[i].alertDatetime.month, alertList[i].alertDatetime.day);
        int durations = widget.expiryDate.difference(alertDatetime).inDays;
        selectedValue.add(durations);
      }

      selectedType = alertList[0].alertIndex;
    }
    if (mounted) {
      setState(() {
        _isSwitchOn = _isDoneSelected = true;
        _alertList = alertList;
        _selectedType = selectedType;
        _selectedValue = selectedValue;
      });
    }
  }

  // #region [ "Add Alert Funtions" ]
  void addAlert() async {
    if (_isDoneSelected) {
      _alertList.clear();
      _selectedValue.sort((a, b) => b.compareTo(a));
      for (int i = 0; i < _selectedValue.length; i++) {
        int hour =
            int.parse(widget.userDetails.preferredAlertTime.split(':')[0]);
        int minute =
            int.parse(widget.userDetails.preferredAlertTime.split(':')[1]);

        String alertName =
            widget.productName == null || widget.productName == ""
                ? 'Untitled Alert ${i + 1}'
                : 'Alert ${i + 1} - ${widget.productName} ';
        DateTime alertDatetime = widget.expiryDate
            .subtract(Duration(days: _selectedValue[i]))
            .add(Duration(hours: hour, minutes: minute));
        List<int> alertIndex = List.castFrom(_selectedType);
        _alertList.add(new Alert(
            alertName: alertName,
            alertDatetime: alertDatetime,
            alertIndex: alertIndex));
      }
      setState(() {
        if (widget.onChanged != null) {
          widget.onChanged(_alertList);
        }
      });
    }
  }
  // #endregion

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
    return "";
  }
  // #endregion

  // #region [ "Checkbox Options - Alert Date Options" ]
  List<FormBuilderFieldOption<dynamic>> _getOptions() {
    List<FormBuilderFieldOption<dynamic>> optionList = [];
    int days = widget.expiryDate.difference(today).inDays;
    // optionList.add(FormBuilderFieldOption(
    //   value: 0,
    //   child: Text('Select all'),
    // ));
    if (days > 0) {
      optionList.add(FormBuilderFieldOption(
        value: 0,
        child: Text('On that day'),
      ));
    }
    if (days > 1) {
      optionList.add(FormBuilderFieldOption(
        value: 1,
        child: Text('One day before'),
      ));
    }
    if (days > 3) {
      optionList.add(FormBuilderFieldOption(
        value: 3,
        child: Text('Three days before'),
      ));
    }
    if (days > 7) {
      optionList.add(FormBuilderFieldOption(
        value: 7,
        child: Text('One week before'),
      ));
    }
    if (days > 14) {
      optionList.add(FormBuilderFieldOption(
        value: 14,
        child: Text('Two weeks before'),
      ));
    }
    if (days > 30) {
      optionList.add(FormBuilderFieldOption(
        value: 30,
        child: Text('One month before'),
      ));
    }
    if (days > 60) {
      optionList.add(FormBuilderFieldOption(
        value: 60,
        child: Text('Two months before'),
      ));
    }
    if (days > 90) {
      optionList.add(FormBuilderFieldOption(
        value: 90,
        child: Text('Three months before'),
      ));
    }
    if (days > 180) {
      optionList.add(FormBuilderFieldOption(
        value: 180,
        child: Text('Six months before'),
      ));
    }
    return optionList;
  }

  // #endregion

  // #region [ "Checkbox Options - Alert Type Options" ]
  List<FormBuilderFieldOption<dynamic>> _getAlertType() {
    List<FormBuilderFieldOption<dynamic>> alertTypeList = [];
    alertTypeList.add(FormBuilderFieldOption(
        value: 0, child: Text('Push Notification Reminder')));
    if (widget.userDetails.isPhoneVerify) {
      alertTypeList.add(FormBuilderFieldOption(
          value: 1, child: Text('SMS Notification Reminder')));
    }
    if (widget.userDetails.isEmailVerify) {
      alertTypeList.add(FormBuilderFieldOption(
          value: 2, child: Text('Email Notification Reminder')));
    }
    return alertTypeList;
  }

  // #endregion

  // #region [ "Form Builder Item - Add Reminder Button" ]
  Widget _buildAddReminderTile() {
    if (_isSwitchOn) {
      return TextButton.icon(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _addAlertDialog();
                });
          },
          icon: Icon(Icons.add_alert_outlined),
          label: Text('Add Reminder'));
    }
    return Container();
  }
  // #endregion

  // #region [ "Form Builder Item - Display Added Alert" ]
  List<Widget> _displayAlert() {
    if (_isDoneSelected) {
      List<Widget> alertCardList = [];
      addAlert();
      for (int i = 0; i < _alertList.length; i++) {
        List<int> alertIndex = _alertList[i].alertIndex;
        List<Widget> alertFieldIndex = [];
        for (int j = 0; j < alertIndex.length; j++) {
          alertFieldIndex.add(Text(
              printAlertType(AlertType.values[alertIndex[j]]),
              style: Theme.of(context).primaryTextTheme.subtitle2));
        }
        alertCardList.add(Container(
            padding: EdgeInsets.all(10.0),
            child: InputDecorator(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '${_alertList[i].alertName}'),
                child: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alert Date:'),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0)),
                                Text(
                                    DateFormat('dd/MM/yyyy (EEEE)').format(
                                      _alertList[i].alertDatetime,
                                    ),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle2),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alert Time:'),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0)),
                                Text(
                                    DateFormat('hh:mm a').format(
                                      _alertList[i].alertDatetime,
                                    ),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle2),
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
    return [SizedBox.shrink()];
  }
  // #endregion

  // #region [ "Form Builder - Add Alert Date Dialog" ]
  Widget _addAlertDialog() {
    final _formKey = GlobalKey<FormBuilderState>();
    List<dynamic> _initialValue = _selectedValue;
    if (widget.expiryDate.isAfter(now)) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('Select Reminder Date'),
        content: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  FormBuilderCheckboxGroup(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero),
                    name: 'AddAlertChkbox',
                    initialValue: _initialValue,
                    options: _getOptions(),
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value;
                      });
                      print(_selectedValue);
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ]))),
        actions: <Widget>[
          new ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text('CANCEL'),
                textColor: Theme.of(context).accentTextTheme.bodyText1.color,
              ),
              new FlatButton(
                onPressed: () {
                  if (_selectedValue.length > 0) {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _addAlertTypeDialog();
                        });
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Please select at least one reminder date'),
                      action: SnackBarAction(
                          label: 'OKAY',
                          onPressed: () {
                            Scaffold.of(context).hideCurrentSnackBar();
                          }),
                    ));
                  }
                },
                child: Text('NEXT'),
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          )
        ],
      );
    }
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('Error'),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Text('Please select expiry date first.'),
        ),
        actions: <Widget>[
          new ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
                child: Text('OKAY'),
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          )
        ]);
  }
// #endregion

  // #region [ "Form Builder - Add Alert Type Dialog" ]
  Widget _addAlertTypeDialog() {
    final _formKey = GlobalKey<FormBuilderState>();
    List<dynamic> _initialValue = _selectedType;

    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Text('Select Reminder Method'),
      content: FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                FormBuilderCheckboxGroup(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero),
                  name: 'AddAlertChkbox',
                  initialValue: _initialValue,
                  options: _getAlertType(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                    print(_selectedType);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ]))),
      actions: <Widget>[
        new ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _addAlertDialog();
                    });
              },
              child: Text('BACK'),
              textColor: Theme.of(context).accentTextTheme.bodyText1.color,
            ),
            new FlatButton(
              onPressed: () {
                if (_selectedType.length > 0) {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isDoneSelected = true;
                  });
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Please select at least one reminder method'),
                    action: SnackBarAction(
                        label: 'OKAY',
                        onPressed: () {
                          Scaffold.of(context).hideCurrentSnackBar();
                        }),
                  ));
                  setState(() {
                    _isDoneSelected = false;
                  });
                }
              },
              child: Text('SAVE'),
              textColor: Theme.of(context).primaryColor,
            ),
          ],
        )
      ],
    );
  }
  // #endregion

  @override
  Widget build(BuildContext context) {
    // if (widget.isEdit) {
    //   setUpReminderDetails();
    // } else {
    //   for (int i = 0; i < _alertList.length; i++) {
    //     if (_alertList[i]
    //         .alertDatetime
    //         .isAfter(widget.expiryDate.add(Duration(days: 1)))) {
    //       _alertList.clear();
    //       _selectedType.clear();
    //       _selectedValue.clear();
    //       _isDoneSelected = false;
    //     }
    //     break;
    //   }
    // }
    return Container(
        child: Padding(
      padding: EdgeInsets.all(4.0),
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelStyle: Theme.of(context).primaryTextTheme.bodyText1,
          labelText: 'Reminder & Alert',
          contentPadding: EdgeInsets.all(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SwitchListTile.adaptive(
                dense: true,
                title: Text('Reminder'),
                activeColor: Theme.of(context).primaryColor,
                value: _isSwitchOn,
                onChanged: (value) {
                  setState(() {
                    _isSwitchOn = value;
                    if (!_isSwitchOn) {
                      _alertList.clear();
                      _selectedType.clear();
                      _selectedValue.clear();
                      _isDoneSelected = false;
                    }
                  });
                }),
            ..._displayAlert(),
            _buildAddReminderTile(),
          ],
        ),
      ),
    ));
  }
}
