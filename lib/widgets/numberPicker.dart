import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Action { Minus, Add }

class NumberPicker extends StatefulWidget {
  final Function(dynamic) onChanged;
  final dynamic maxValue;
  final dynamic minValue;
  final dynamic initialValue;
  final dynamic step;
  final dynamic labelText;
  final dynamic isResetButton;

  NumberPicker({
    Key key,
    @required this.onChanged,
    @required this.maxValue,
    @required this.minValue,
    @required this.initialValue,
    this.isResetButton = false,
    this.step = 1,
    this.labelText = "",
  })  : assert(initialValue != null),
        assert(initialValue.runtimeType != String),
        assert(isResetButton.runtimeType == bool),
        assert(labelText.runtimeType == String),
        assert(maxValue.runtimeType == initialValue.runtimeType),
        assert(minValue.runtimeType == initialValue.runtimeType),
        super(key: key);

  @override
  _NumberPickerState createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  dynamic _initialValue;
  dynamic _maxValue;
  dynamic _minValue;
  dynamic _step;
  dynamic _labelText;
  dynamic _isResetButton;
  bool _isNumberValid = true;
  // to set the initial value
  TextEditingController textController;

  @override
  void initState() {
    super.initState();
    _initialValue = widget.initialValue;
    _maxValue = widget.maxValue;
    _minValue = widget.minValue;
    _step = widget.step;
    _labelText = widget.labelText;
    _isResetButton = widget.isResetButton;
    textController = TextEditingController(text: widget.minValue.toString());
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: EdgeInsets.all(4.0),
            child: InputDecorator(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: Theme.of(context).primaryTextTheme.bodyText1,
                    contentPadding: EdgeInsets.all(20.0),
                    errorText: _isNumberValid
                        ? null
                        : 'Only allowed number between $_minValue and $_maxValue.',
                    labelText: _labelText != null && _labelText != ""
                        ? _labelText
                        : null),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                      child: OutlineButton(
                        onPressed: () => _minus(),
                        child: Icon(Icons.remove),
                        textColor:
                            Theme.of(context).accentTextTheme.bodyText1.color,
                      ),
                    ),
                    Container(
                        child: Expanded(
                            child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: textController,
                                  showCursor: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]"))
                                  ],
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) {
                                    checkNumberValid();
                                    if (_isNumberValid) {
                                      _initialValue =
                                          int.parse(textController.text);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                  ),
                                )))),
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                      child: OutlineButton(
                        onPressed: () => _add(),
                        child: Icon(Icons.add),
                        textColor:
                            Theme.of(context).accentTextTheme.bodyText1.color,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    _isResetButton
                        ? OutlineButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                _initialValue = widget.initialValue;
                                textController.text = _initialValue.toString();
                                _isNumberValid = true;
                              });
                            },
                            child: Text('Reset'))
                        : Container(),
                  ],
                ))));
  }

  bool isAbleToAction(Action action) {
    if (action == Action.Add) {
      print(_initialValue + _step <= _maxValue);
      return _initialValue + _step <= _maxValue;
    }
    if (action == Action.Minus) {
      print(_initialValue - _step >= _minValue);
      return _initialValue - _step >= _minValue;
    }
    return false;
  }

  void checkNumberValid() {
    if (int.parse(textController.text) < _minValue ||
        int.parse(textController.text) > _maxValue) {
      setState(() {
        _isNumberValid = false;
      });
    } else {
      setState(() {
        _isNumberValid = true;
      });
    }
  }

  void _minus() {
    if (isAbleToAction(Action.Minus)) {
      setState(() {
        _initialValue -= _step;
        textController.text = _initialValue.toString();
      });
    }
    if (widget.onChanged != null) {
      widget.onChanged(_initialValue);
    }
    checkNumberValid();
  }

  void _add() {
    if (isAbleToAction(Action.Add)) {
      setState(() {
        _initialValue += _step;
        textController.text = _initialValue.toString();
      });
    }
    if (widget.onChanged != null) {
      widget.onChanged(_initialValue);
    }
    checkNumberValid();
  }
}
