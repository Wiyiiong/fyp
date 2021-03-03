import 'package:expiry_reminder/models/alertModel.dart';
import 'package:expiry_reminder/models/personalProductModel.dart';
import 'package:expiry_reminder/models/userModel.dart';
import 'package:expiry_reminder/pages/Product/InstructionPage.dart';
import 'package:expiry_reminder/services/cloudMessagingServices.dart';
import 'package:expiry_reminder/services/dateDetectorServices.dart';
import 'package:expiry_reminder/services/productServices.dart';
import 'package:expiry_reminder/services/userServices.dart';
import 'package:expiry_reminder/widgets/ReminderAlert.dart';
import 'package:expiry_reminder/widgets/numberPicker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../utils/ThemeData.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductActionPage extends StatefulWidget {
  final String currentUserId;
  final bool isEdit;
  final String productId;

  ProductActionPage(
      {this.currentUserId, this.isEdit = false, this.productId = ""});

  @override
  _ProductActionPageState createState() => _ProductActionPageState();
}

class _ProductActionPageState extends State<ProductActionPage>
    with SingleTickerProviderStateMixin {
  // User details
  User _userDetails = new User();
  // Product
  PersonalProduct _product = new PersonalProduct();
  // For keyboard animation
  AnimationController _animationController;
  Animation _animation;

  FocusNode _focusNode;

  // Date picker controller
  TextEditingController datetimeController;

  // image picker
  final imagePicker = ImagePicker();

  // form key
  final _newCategoryKey = GlobalKey<FormFieldState>();
  final _formKey = GlobalKey<FormState>();

  // drop down list items
  List<String> _dropdownListItems = [];

  // Selected items from picker and Drop down
  /// Image file for product added
  File _image;
  String _imageUrl;

  /// Selected Category
  String _category = "None";

  /// Selected date
  DateTime _selectedDate;

  /// Scanned barcode
  String _barcode;

  /// Selected number of stocks
  int _numStocks;
  int _minValue;

  /// today's date
  DateTime today;

  /// reminder & alert
  List<Alert> _alertList = new List<Alert>();

  /// OCR Readers
  int _ocrCamera = FlutterMobileVision.CAMERA_BACK;

  bool _isSwitchedOn;

  /// Text Editing Controllers
  TextEditingController productNameController = new TextEditingController();
  TextEditingController barcodeController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController newCategoryController = new TextEditingController();

  /// Page View Controllers
  PageController pageViewController = new PageController();

  @override
  void initState() {
    super.initState();
    _isSwitchedOn = false;
    if (widget.isEdit && widget.productId.isNotEmpty) {
      _setupEditProductPage();
    } else {
      _setupAddProductPage();
    }

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 300.0, end: 50.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    CloudMessagingService.getNotification(context);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _focusNode.dispose();
  }

  _setupAddProductPage() async {
    List<dynamic> dropdownListItems =
        await ProductService.getCategory(widget.currentUserId);
    User userDetails = await UserService.getUserDetails(widget.currentUserId);

    if (mounted) {
      setState(() {
        _dropdownListItems = dropdownListItems;
        _userDetails = userDetails;
        _category = "None";
        _selectedDate = new DateTime.now();
        _barcode = "";
        _numStocks = 1;
        _minValue = 1;
        _imageUrl = null;
        today = new DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        _alertList = [];
        productNameController = new TextEditingController();
        barcodeController = new TextEditingController();
        descriptionController = new TextEditingController();
        newCategoryController = new TextEditingController();
        datetimeController = new TextEditingController();
      });
    }
  }

  _setupEditProductPage() async {
    List<dynamic> dropdownListItems =
        await ProductService.getCategory(widget.currentUserId);
    PersonalProduct product = await ProductService.getProductById(
        widget.currentUserId, widget.productId);
    User userDetails = await UserService.getUserDetails(widget.currentUserId);

    if (mounted) {
      setState(() {
        _dropdownListItems = dropdownListItems;
        _userDetails = userDetails;
        _product = product;
        _category = '${product.category}';
        _selectedDate = product.expiryDate;
        _barcode = '${product.barcode ?? "-"}';
        _numStocks = product.numStocks;
        _minValue = 0;
        _imageUrl = product.image;
        today = new DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        _alertList = product.alerts ?? [];
        if (_alertList.length > 0) {
          _isSwitchedOn = true;
        }
        productNameController =
            new TextEditingController(text: '${product.productName ?? ''}');
        barcodeController = new TextEditingController(text: _barcode);
        descriptionController =
            new TextEditingController(text: '${product.description ?? "-"}');
        newCategoryController = new TextEditingController();
        datetimeController = new TextEditingController(
            text: DateFormat('dd-MM-yyyy (EEEE)').format(_selectedDate) ?? '');
      });
    }
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

  Future checkFirstCrop() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool _seen = (prefs.getBool('cropDate') ?? false);

    // if (!_seen) {
    // await prefs.setBool('cropDate', true);
    Navigator.of(context)
        .push(PageRouteBuilder(
            fullscreenDialog: true,
            pageBuilder: (BuildContext context, _, __) => InstructionPage()))
        .then((value) => getDateImage());
    // }
  }

  // #region [ "Submit Form - Add Product" ]
  Future addProduct() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _showLoadingDialog(context);
      String imageUrl;
      if (_image != null) {
        imageUrl = await ProductService.uploadProductImage(_image);
      }
      PersonalProduct product = new PersonalProduct(
        image: imageUrl == null ? null : imageUrl.trim(),
        productName: productNameController.text.trim(),
        description: descriptionController.text.trim() == ""
            ? null
            : descriptionController.text.trim(),
        barcode: barcodeController.text.trim() == '-1' ||
                barcodeController.text.trim() == ""
            ? null
            : barcodeController.text.trim(),
        numStocks: _numStocks,
        expiryDate: _selectedDate,
        category: _category,
      );
      product.alerts = _alertList;
      await ProductService.removeUnuseCategory(_category, widget.currentUserId);
      await ProductService.addNewPersonalProduct(product, widget.currentUserId);
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
                  Text('Added Successfully!',
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
  }
  // #endregion

  // #region [ "Submit Form - Edit Product" ]
  Future editProduct() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _showLoadingDialog(context);

      String imageUrl;
      if (_image != null) {
        imageUrl = await ProductService.uploadProductImage(_image);
      }
      PersonalProduct product = new PersonalProduct(
        id: widget.productId,
        image: imageUrl == null ? null : imageUrl.trim(),
        productName: productNameController.text.trim(),
        description: descriptionController.text.trim() == ""
            ? null
            : descriptionController.text.trim(),
        barcode: barcodeController.text.trim() == '-1' ||
                barcodeController.text.trim() == ""
            ? null
            : barcodeController.text.trim(),
        numStocks: _numStocks,
        expiryDate: _selectedDate,
        category: _category,
      );
      product.alerts = _alertList;
      await ProductService.removeUnuseCategory(_category, widget.currentUserId);
      await ProductService.editPersonalProduct(product, widget.currentUserId);
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
                  Text('Edited Successfully!',
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
  }
  // #endregion

  // #region [ "Form Item - Add Product Form"]

  // #region [ "Image Picker - Product Image Picker" ]
  Future getProductImage() async {
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      final pickedFile = await imagePicker.getImage(source: ImageSource.camera);

      if (pickedFile != null) {
        File cropped = await ImageCropper.cropImage(
            sourcePath: pickedFile.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Theme.of(context).backgroundColor,
                toolbarWidgetColor:
                    Theme.of(context).primaryTextTheme.headline1.color,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));
        setState(() {
          _image = cropped ?? File(pickedFile.path);
        });
      }
    }
  }
  // #endregion

  // #region [ "Image Cropper - Product Image Cropper" ]
  Future cropProductImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).backgroundColor,
            toolbarWidgetColor:
                Theme.of(context).primaryTextTheme.headline1.color,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      _image = cropped ?? _image;
    });
  }
  // #endregion

  // #region [ "Image Picker - Date Image Picker" ]
  Future getDateImage() async {
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      final pickedFile = await imagePicker.getImage(source: ImageSource.camera);

      if (pickedFile != null) {
        File cropped = await ImageCropper.cropImage(
            sourcePath: pickedFile.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Theme.of(context).backgroundColor,
                toolbarWidgetColor:
                    Theme.of(context).primaryTextTheme.headline1.color,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 0.01,
            ));
        print('CROPPED!!!!!!');
        if (cropped != null) {
          _showLoadingDialog(context);
          DateTime date = await DateDetectorService.getPredictedResult(cropped);
          if (date != null) {
            String formatedDate = DateFormat('dd/MM/yyyy (EEEE)').format(date);
            setState(() {
              _selectedDate = date;
              datetimeController.text = formatedDate;
            });
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('Error Occurred'),
                      content: Text('Failed To Identify Date'),
                      actions: [
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OKAY'))
                      ],
                    ));
          }
        }
      }
    }
  }

  // #endregion

  // #region [ "Barcode Scanner - barcode scanner"]
  Future scanBarcode() async {
    String barcode;
    try {
      barcode = await FlutterBarcodeScanner.scanBarcode(
          '#00ff55', "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcode = 'Failed to get platform version.';
    }

    if ((barcode != null || barcode != "" || barcode != '-1') &&
        barcode != _barcode) {
      setState(() {
        _barcode = barcode;
        barcodeController.text = barcode;
      });
    }
  }
  // #endregion

  // #region[ "Date Picker - Expiry Date Picker" ]
  Future getExpiryDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: (365 * 6))),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        String formatedDate =
            DateFormat('dd/MM/yyyy (EEEE)').format(_selectedDate);
        datetimeController.text = formatedDate;
      });

      /// Alert
      ReminderAlert(
        expiryDate: _selectedDate,
        userDetails: _userDetails,
        onChanged: (alertList) {
          _alertList = alertList;
        },
        productName: productNameController.text,
        productId: widget.productId,
        isEdit: _isSwitchedOn,
      );
    }
  }
  // #endregion

  // #region [ "Dropdown List - Category Dropdown List" ]
  _buildCategoryDropDownList() {
    return DropdownButtonFormField<String>(
      value: _category,
      hint: Text('Select Product Category'),
      isExpanded: true,
      isDense: true,
      focusColor: Theme.of(context).primaryColor,
      items: _dropdownListItems.map((String category) {
        return new DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String value) {
        setState(() {
          _category = value;
        });
      },
      decoration: const InputDecoration(
          hintText: 'Product Category',
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
          labelText: 'Product Category'),
      validator: (value) => value == null ? 'Field Required' : null,
    );
  }
  // #endregion

  // #region [ "Alert Dialog - Add Category Alert Dialog" ]
  Widget _buildAddCategoryDialog(BuildContext context) {
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
                    } else if (_dropdownListItems.contains(value.trim())) {
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
                        !_dropdownListItems
                            .contains(newCategoryController.text)) {
                      _showLoadingDialog(context);

                      await ProductService.addNewCategory(
                          newCategoryController.text.trim(),
                          widget.currentUserId);

                      List<dynamic> dropdownListItems =
                          await ProductService.getCategory(
                              widget.currentUserId);
                      setState(() {
                        _dropdownListItems = dropdownListItems;
                        _category = newCategoryController.text;
                        newCategoryController.text = "";
                      });
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
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

  // #region [ "Alert Dialog - Upload Photo Alert Dialog" ]

  Widget _buildUploadImageDialog(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 3)),
            // Text(
            //   'Edit Product Photo',
            //   style: Theme.of(context).primaryTextTheme.bodyText1,
            // ),
            // Padding(padding: EdgeInsets.symmetric(vertical: 3)),
            // Divider(),
            ListTile(
              title: Center(
                  child: Text('CHANGE PHOTO',
                      style: TextStyle(color: Theme.of(context).primaryColor))),
              onTap: () {
                getProductImage();
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
            ),
            ListTile(
              title: Center(
                  child: Text('CROP PHOTO',
                      style: TextStyle(color: Theme.of(context).primaryColor))),
              onTap: () {
                cropProductImage();
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
            ),
            ListTile(
              title: Center(
                  child: Text('REMOVE PHOTO', style: TextStyle(color: danger))),
              onTap: () {
                setState(() {
                  _image = null;
                });
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
            ),
            Divider(
              height: 0.5,
            ),
            ListTile(
              title: Center(
                  child: Text('CANCEL',
                      style:
                          TextStyle(color: Theme.of(context).disabledColor))),
              onTap: () {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ));
  }
  // #endregion

  // #region [ "OCR - Read Product Name" ]
  Future _readOCR() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(camera: _ocrCamera, waitTap: true);
      setState(() {
        productNameController.text = texts[0].value;
      });
    } on Exception {
      texts.add(OcrText('Failed to recognize text'));
    }
  }
  // #endregion

  // #endregion

  // #region [ "Widget - Add Product Form" ]
  Widget _buildAddProductForm() {
    if (_dropdownListItems.length == 0) {
      return Center(child: CircularProgressIndicator());
    }
    if (widget.isEdit && _product == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        child: Column(
                      children: [
                        /// Insert product image
                        Container(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          width: MediaQuery.of(context).size.width - 40,
                          height: MediaQuery.of(context).size.height * 0.3 - 20,
                          child: InkWell(
                            child: widget.isEdit
                                ? _image == null && _imageUrl == null
                                    ? Image.asset(
                                        'assets/image/image_placeholder.png',
                                      )
                                    : _image == null
                                        ? Image.network(
                                            _product.image,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                          )
                                        : Image.file(_image)
                                : _image == null
                                    ? Image.asset(
                                        'assets/image/image_placeholder.png',
                                      )
                                    : Image.file(_image),
                            splashColor: Colors.transparent,
                            onTap: () {
                              if ((widget.isEdit && _imageUrl != null) ||
                                  _image != null) {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildUploadImageDialog(context),
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))));
                              } else if (_image == null) {
                                getProductImage();
                              }
                            },
                          ),
                        ),
                      ],
                    )),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),
                    InputDecorator(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Product Information',
                            labelStyle:
                                Theme.of(context).primaryTextTheme.bodyText1,
                            contentPadding: EdgeInsets.all(20.0)),
                        child: Column(
                          children: [
                            /// Padding
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                            ),

                            /// Product name
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              controller: productNameController,
                              validator: (value) => value.isEmpty
                                  ? 'Product name can\'t be empty'
                                  : null,
                              decoration: InputDecoration(
                                  hintText: 'Product Name',
                                  labelText: 'Product Name',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10.0)),
                              onEditingComplete: () {
                                /// Alert
                                ReminderAlert(
                                  expiryDate: _selectedDate,
                                  userDetails: _userDetails,
                                  onChanged: (alertList) {
                                    _alertList = alertList;
                                  },
                                  productName: productNameController.text,
                                  productId: widget.productId,
                                  isEdit: _isSwitchedOn,
                                );
                              },
                            ),

                            /// Padding
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                            ),

                            /// Category
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 6.0,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: _buildCategoryDropDownList(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  widthFactor: 3,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              _buildAddCategoryDialog(context));
                                    },
                                    icon: Icon(Icons.add_circle_outline,
                                        size: 18),
                                    label: Text('Add Category'),
                                  ),
                                )
                              ],
                            ),

                            /// Padding
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                            ),

                            /// Date picker
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 6.0,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      child: TextFormField(
                                        controller: datetimeController,
                                        validator: (value) => value.isEmpty
                                            ? 'Date can\'t be empty'
                                            : null,
                                        decoration: InputDecoration(
                                            hintText:
                                                'Select Expiry Date (dd/MM/yyyy)',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                            labelText: 'Expiry Date'),
                                        readOnly: true,
                                        onTap: () => getExpiryDate(context),
                                      )),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  widthFactor: 5.0,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      checkFirstCrop();
                                    },
                                    icon: Icon(Icons.center_focus_weak_outlined,
                                        size: 18),
                                    label: Text('Scan Date'),
                                  ),
                                )
                              ],
                            ),

                            /// Padding
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                            ),

                            /// Barcode
                            TextFormField(
                              controller: barcodeController,
                              decoration: InputDecoration(
                                helperText: 'Tap to scan product barcode',
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10.0),
                                labelText: 'Barcode',
                              ),
                              // suffix: barcodeController?.text != ""
                              //     ? IconButton(
                              //         icon: Icon(Icons.clear_outlined,
                              //             color: Theme.of(context)
                              //                 .accentTextTheme
                              //                 .bodyText1
                              //                 .color,
                              //             size: 12.0),
                              //         onPressed: () {
                              //           barcodeController.text = "";
                              //         },
                              //       )
                              //     : null),
                              readOnly: true,
                              onTap: () {
                                scanBarcode();
                              },
                            ),

                            /// Padding
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                            ),

                            /// Product Description
                            TextFormField(
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Description (Optional)',
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10.0),
                                labelText: 'Description (Optional)',
                              ),
                            ),

                            /// Padding
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                            ),
                          ],
                        )),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),

                    /// Stock Count
                    NumberPicker(
                      onChanged: (value) {
                        setState(() {
                          _numStocks = value;
                        });
                      },
                      maxValue: 9999,
                      minValue: _minValue,
                      initialValue: _numStocks,
                      step: 1,
                      isResetButton: true,
                      labelText: 'Stock Number',
                    ),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),

                    /// Alert
                    ReminderAlert(
                      expiryDate: _selectedDate,
                      userDetails: _userDetails,
                      onChanged: (alertList) {
                        _alertList = alertList;
                      },
                      productName: productNameController.text,
                      productId: widget.productId,
                      isEdit: _isSwitchedOn,
                    ),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),

                    FlatButton(
                      child: Text('Scan Product Name Using OCR'),
                      onPressed: () async {
                        await _readOCR();
                      },
                    ),

                    /// Padding
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                  ],
                ),
              ),
            ),
          ))
        ]));
  }

  // #endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Expiry Reminder',
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Center(
                  child: IconButton(
                      icon: Icon(Icons.done_outlined),
                      onPressed: () {
                        if (widget.isEdit) {
                          editProduct();
                        } else {
                          addProduct();
                        }
                      }))),
        ],
        centerTitle: true,
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: _buildAddProductForm(),
      ),
    );
  }
}
