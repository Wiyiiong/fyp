import 'package:flutter/material.dart';

class ErrorDialog extends StatefulWidget {
  final String errorTitle;
  final String errorMessage;

  ErrorDialog({@required this.errorTitle, @required this.errorMessage});

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.errorTitle),
      content: Text(widget.errorMessage),
      actions: [
        TextButton(
            child: Text('OKAY'), onPressed: () => Navigator.of(context).pop())
      ],
    );
  }
}
