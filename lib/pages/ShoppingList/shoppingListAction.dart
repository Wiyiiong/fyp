import 'package:expiry_reminder/models/shoppingListModel.dart';
import 'package:expiry_reminder/services/shoppingListService.dart';
import 'package:flutter/material.dart';

class ShoppingListAction extends StatefulWidget {
  final String currentUserId;
  final bool isEdit;
  final ShoppingList shoppingListItem;

  ShoppingListAction(
      {@required this.currentUserId,
      this.isEdit = false,
      this.shoppingListItem});

  @override
  _ShoppingListActionState createState() => _ShoppingListActionState();
}

class _ShoppingListActionState extends State<ShoppingListAction> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController productNameController;
  TextEditingController descriptionController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.isEdit ? _setupEditShoppingList() : _setupAddShoppingList();
  }

  void _setupEditShoppingList() {
    productNameController =
        new TextEditingController(text: widget.shoppingListItem.productName);
    descriptionController =
        new TextEditingController(text: widget.shoppingListItem.description);
  }

  void _setupAddShoppingList() {
    productNameController = new TextEditingController();
    descriptionController = new TextEditingController();
  }

  void _showDoneDialog() {
    Navigator.of(context).pop();

    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Theme.of(context).splashColor,
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Icon(Icons.done_all_outlined,
                        size: 28.0,
                        color: Theme.of(context).primaryIconTheme.color)),
                widget.isEdit
                    ? Text('Edited Successfully!',
                        style: Theme.of(context).primaryTextTheme.headline5)
                    : Text('Added Successfully!',
                        style: Theme.of(context).primaryTextTheme.headline5),
                Text('Redirect back to Home Page',
                    style: Theme.of(context).primaryTextTheme.bodyText2),
                Padding(padding: EdgeInsets.symmetric(vertical: 20.0))
              ],
            ),
          ));
        });
    new Future.delayed(new Duration(seconds: 3), () {
      Navigator.pop(context); //pop dialog
      Navigator.pop(context); // pop page
    });
  }

  _showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).splashColor,
        builder: (context) => AlertDialog(
              elevation: 0.0,
              content: Center(child: CircularProgressIndicator()),
              backgroundColor: Colors.transparent,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          /// Title
          widget.isEdit
              ? Center(
                  child: Text('Edit Shopping List Item',
                      style: Theme.of(context).primaryTextTheme.headline6))
              : Center(
                  child: Text('Add Shopping List Item',
                      style: Theme.of(context).primaryTextTheme.headline6)),

          /// Padding
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),

          /// Divider
          Divider(
            height: 20,
          ),

          /// Product Name
          TextFormField(
            controller: productNameController,
            validator: (value) =>
                value.isEmpty ? 'Product name can\'t be empty' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: 'Product Name'),
          ),

          /// Padding
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),

          /// Description
          TextFormField(
            controller: descriptionController,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Description (Optional) ',
              hintText: 'Specify product\'s brand, quantity and etc.',
            ),
            maxLength: 50,
          ),

          /// Padding
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          ElevatedButton(
              child: Padding(
                  child: Text('Save'),
                  padding: EdgeInsets.symmetric(horizontal: 30.0)),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  _showLoadingDialog(context);

                  if (widget.isEdit) {
                    ShoppingList shoppingListItem = new ShoppingList(
                        productName: productNameController.text,
                        description: descriptionController.text,
                        isDone: widget.shoppingListItem.isDone,
                        createdDateTime: DateTime.now(),
                        productId: widget.shoppingListItem.productId);

                    await ShoppingListService.editShoppingList(
                            widget.currentUserId,
                            widget.shoppingListItem.id,
                            shoppingListItem)
                        .then((value) => _showDoneDialog());
                  } else {
                    ShoppingList shoppingListItem = new ShoppingList(
                        productName: productNameController.text,
                        description: descriptionController.text,
                        createdDateTime: DateTime.now());
                    await ShoppingListService.addShoppingList(
                            widget.currentUserId, shoppingListItem)
                        .then((value) => _showDoneDialog());
                  }
                }
              }),
        ]),
      ),
    );
    // Scaffold(
    //     resizeToAvoidBottomInset: false,
    //     appBar: AppBar(
    //       title: Text('Add Shopping List'),
    //       actions: <Widget>[
    //         Padding(
    //           padding: EdgeInsets.only(right: 10.0),
    //           child: IconButton(
    //               icon: Icon(Icons.done, size: 28.0),
    //               onPressed: () async {

    //               }),
    //         )
    //       ],
    //     ),
    //     body: );
  }
}
