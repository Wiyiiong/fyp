import 'package:expiry_reminder/services/cloudMessagingServices.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/services/userAuthServices.dart';
import 'package:expiry_reminder/utils/ThemeData.dart';
import 'package:expiry_reminder/widgets/MyDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'productByCategory.dart';

class SearchByCategory extends StatefulWidget {
  @override
  _SearchByCategoryState createState() => _SearchByCategoryState();
}

class _SearchByCategoryState extends State<SearchByCategory> {
  dynamic _currentUserId;
  dynamic _categoryList;

  /// form key
  final _newCategoryKey = GlobalKey<FormFieldState>();
  final _editCategoryKey = GlobalKey<FormFieldState>();

  /// Text Editing Controller
  TextEditingController newCategoryController = new TextEditingController();
  TextEditingController editCategoryController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupCategory();
    // CloudMessagingService.getNotification(context);
  }

  _setupCategory() async {
    if (mounted) {
      setState(() {
        _currentUserId = UserAuthService.getCurrentUser().uid;
        _categoryList = ProductService.getCategory(_currentUserId);
      });
    }
  }

  // #region [ "Alert Dialog - Add Category Alert Dialog" ]
  Widget _buildAddCategoryDialog(
      BuildContext context, List<String> categoryList) {
    return new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('Add New Category'),
        content: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// New Category Name
                TextFormField(
                  key: _newCategoryKey,

                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: newCategoryController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return 'Category cannot be empty';
                    } else if (categoryList.contains(value.trim())) {
                      return 'Category already exist';
                    }
                    return null;
                  },
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      hintText: 'New Category Name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0)),
                ),
              ],
            )),
        actions: <Widget>[
          new ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  setState(() {
                    newCategoryController.text = "";
                  });
                },
                child: Text('CANCEL'),
                textColor: Theme.of(context).accentTextTheme.bodyText1.color,
              ),
              FlatButton(
                onPressed: () async {
                  if (_newCategoryKey.currentState.validate()) {
                    if (newCategoryController.text.trim().isNotEmpty &&
                        !categoryList.contains(newCategoryController.text)) {
                      ProductService.addNewCategory(
                          newCategoryController.text.trim(), _currentUserId);
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierColor: Theme.of(context).splashColor,
                          builder: (BuildContext context) {
                            return Dialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0.0,
                                child: Expanded(
                                    child: SizedBox.expand(
                                        child: Center(
                                            child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .primaryColor)),
                                    Text('Loading...',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText1)
                                  ],
                                )))));
                          });

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      _setupCategory();
                      newCategoryController.text = "";
                    }
                  }
                },
                child: Text('ADD'),
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          )
        ]);
  }
  // #endregion

  Widget _buildEditCategoryDialog(
      BuildContext context, List<String> categoryList, String category) {
    editCategoryController.text = category;
    return new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('Edit Category Name'),
        content: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// New Category Name
                TextFormField(
                  key: _editCategoryKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: editCategoryController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return 'Category cannot be empty';
                    } else if (categoryList.contains(value.trim())) {
                      return 'Category already exist';
                    }
                    return null;
                  },
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      hintText: 'Category Name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0)),
                ),
              ],
            )),
        actions: <Widget>[
          new ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  setState(() {
                    newCategoryController.text = "";
                  });
                },
                child: Text('CANCEL'),
                textColor: Theme.of(context).accentTextTheme.bodyText1.color,
              ),
              FlatButton(
                onPressed: () async {
                  if (_editCategoryKey.currentState.validate()) {
                    if (editCategoryController.text.trim().isNotEmpty &&
                        !categoryList.contains(editCategoryController.text)) {
                      ProductService.editCategory(category,
                          editCategoryController.text, _currentUserId);
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Theme.of(context).splashColor,
                          builder: (BuildContext context) {
                            return Dialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0.0,
                                child: Expanded(
                                    child: SizedBox.expand(
                                        child: Center(
                                            child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .primaryColor)),
                                    Text('Loading...',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText1)
                                  ],
                                )))));
                          });

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      editCategoryController.text = "";
                      _setupCategory();
                    }
                  }
                },
                child: Text('DONE'),
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          )
        ]);
  }

  Widget _buildDeleteCategoryDialog(BuildContext context, String category) {
    return new AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Text('Delete Category'),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.18,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RichText(
              text: TextSpan(
                  text: 'Are you sure you want to delete ',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryTextTheme.bodyText2.color,
                      height: 1.2),
                  children: <TextSpan>[
                TextSpan(
                    text: '$category ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: 'and '),
                TextSpan(
                    text: 'all of its products?',
                    style: TextStyle(fontWeight: FontWeight.bold))
              ])),
          Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          Text('*All product under this category will be deleted.',
              style: TextStyle(color: danger, fontSize: 14.0)),
        ]),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('CANCEL',
                style: TextStyle(
                    color: Theme.of(context).accentTextTheme.headline1.color))),
        FlatButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: Theme.of(context).splashColor,
                  builder: (BuildContext context) {
                    return Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0.0,
                        child: Expanded(
                            child: SizedBox.expand(
                                child: Center(
                                    child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor)),
                            Text('Loading...',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText1)
                          ],
                        )))));
                  });
              await ProductService.deleteCategory(category, _currentUserId);
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              _setupCategory();
            },
            child: Text('DELETE')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Category'),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: IconButton(
                    icon: Icon(Icons.add, size: 28.0),
                    onPressed: () async {
                      List<String> categoryList =
                          await ProductService.getCategory(_currentUserId);
                      if (categoryList == null) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) => new Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ));
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _buildAddCategoryDialog(context, categoryList));
                      }
                    })),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _setupCategory(),
          child: FutureBuilder(
              future: _categoryList,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<String> categoryList = snapshot.data;
                return ListView.builder(
                    itemCount: categoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String category = categoryList[index];
                      return category == 'None'
                          ? Card(
                              child: ListTile(
                              dense: false,
                              title: Text(category,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headline6),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductByCategory(
                                      category: category,
                                      currentUserId: _currentUserId,
                                    ),
                                  ),
                                );
                              },
                            ))
                          : Slidable(
                              child: Card(
                                  child: ListTile(
                                dense: false,
                                title: Text(category,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductByCategory(
                                        category: category,
                                        currentUserId: _currentUserId,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                      context: context,
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20))),
                                      builder: (BuildContext context) {
                                        return Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 3)),
                                                // Text(
                                                //   'Edit Product Photo',
                                                //   style: Theme.of(context).primaryTextTheme.bodyText1,
                                                // ),
                                                // Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                                                // Divider(),
                                                ListTile(
                                                  title: Center(
                                                      child: Text('Edit',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor))),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            _buildEditCategoryDialog(
                                                                context,
                                                                categoryList,
                                                                category));
                                                  },
                                                ),
                                                ListTile(
                                                  title: Center(
                                                      child: Text('Delete',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor))),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            _buildDeleteCategoryDialog(
                                                                context,
                                                                category));
                                                  },
                                                ),

                                                Divider(
                                                  height: 0.5,
                                                ),
                                                ListTile(
                                                  title: Center(
                                                      child: Text('CANCEL',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor))),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                ),
                                              ],
                                            ));
                                      });
                                },
                              )),
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.2,
                              secondaryActions: [
                                IconSlideAction(
                                    caption: 'Edit',
                                    color: Colors.blue,
                                    icon: Icons.edit,
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              _buildEditCategoryDialog(context,
                                                  categoryList, category));
                                    }),
                                IconSlideAction(
                                    caption: 'Delete',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              _buildDeleteCategoryDialog(
                                                  context, category));
                                    }),
                              ],
                            );
                    });
              }),
        ),
        drawer: MyDrawer(isCategory: true));
  }
}
