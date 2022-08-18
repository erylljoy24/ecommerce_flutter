import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/models/drop.dart';
import 'package:magri/models/dropproduct.dart';
import 'package:magri/services/base_client.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:magri/widgets/modals/contribution_added_modal.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class AddContribution extends StatefulWidget {
  final String mode;
  final Drop? drop;
  final DropProduct? product;

  AddContribution({this.mode = 'add', this.drop, this.product});
  @override
  State<StatefulWidget> createState() => new _AddContributionState();
}

class _AddContributionState extends State<AddContribution> {
  bool _isLoading = false;
  bool _enableButton = false;

  final _qtyController = TextEditingController();

  DecorationImage? _roundImage;

  List _files = [];

  bool _hasSelectedImages = true;

  List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';

  String _fileErrorMessage = '';

  late File _image;
  final picker = ImagePicker();
  dynamic _pickImageError;
  bool isVideo = false;

  Color? _dashedBoxColor = Colors.grey[600];

  Widget buildGridView() {
    return GridView.count(
      crossAxisSpacing: 5,
      crossAxisCount: 4,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        print(asset.name);
        return showImage(asset, index);
      }),
    );
  }

  Widget showImage(Asset asset, int index) {
    return Stack(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            )),
        Positioned(
          child: GestureDetector(
            onTap: () {
              setState(() {
                images.removeAt(index);
              });
            },
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[400], // change to transparent if offline
              ),
              child: Icon(
                Icons.close,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
          top: -1,
          right: 3,
        ),
      ],
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#049229",
          actionBarTitle: "MAgri App Upload Photo",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      print(error);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _dashedBoxColor = Colors.grey[600];
      _error = error;
    });
  }

  void selectAction() {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Actions'),
      actions: <BottomSheetAction>[
        BottomSheetAction(
            title: const Text('Take Photo'),
            onPressed: () {
              getImage(ImageSource.camera);
            }),
        BottomSheetAction(
            title: const Text('Photo Library'),
            onPressed: () {
              //getImage(ImageSource.gallery);
              loadAssets();
            }),
      ],
      cancelAction: CancelAction(
          title: const Text(
              'Cancel')), // onPressed parameter is optional by default will dismiss the ActionSheet
    );
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print(_image.path);
        var image = Image.file(_image);
        //images.add(_image);
      } else {
        print('No image selected.');
      }
    });

    // Navigator.of(context).pop();
  }

  Future submitProduct(BuildContext context) async {
    Map<String, dynamic> payload = {
      "product_id": widget.product!.id,
      "qty": _qtyController.text,
      "mode": widget.mode,
      "files": _files
    };

    print(payload);

    contributionAddedModal(context);

    return;
    var data = await BaseClient().post(
        '/events/' + widget.drop!.id!.toString() + '/contribute', payload);

    if (data['id'] != null) {
      return true;
    }

    return false;
    // final SharedPreferences prefs = await _prefs;
    // String? token = await prefs.getString('token');

    // var bearerToken = 'Bearer ' + token.toString();
    // var url = Uri.parse(Constants.postProduct);

    // // print(url.path);
    // http
    //     .post(url,
    //         headers: <String, String>{
    //           'Content-Type': 'application/json',
    //           'Authorization': bearerToken
    //         },
    //         body: json.encode(<dynamic, dynamic>{
    //           "product_id": widget.product!.id,
    //           "qty": _qtyController.text,
    //           "mode": widget.mode,
    //           "files": _files
    //         }))
    //     .then((res) {
    //   print(res.statusCode);
    //   if (res.statusCode == 413) {
    //     //
    //     setState(() {
    //       _isLoading = false;
    //       _dashedBoxColor = Colors.red;
    //       _fileErrorMessage = 'Upload smaller file size';
    //     });
    //     print('upload smaller file size');

    //     return;
    //   }
    //   print('Done.');
    //   Navigator.pop(context, {"result": "success"});
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }).catchError((err) {
    //   print(err);
    // });
  }

  Future contributeProduct() async {
    print('post product');
    if (_formKey.currentState!.validate()) {
      // Process
      setState(() {
        _fileErrorMessage = '';
        _isLoading = true;
      });

      // If no images selected and update mode
      if (images.length == 0 && widget.mode == 'edit') {
        submitProduct(context);
        print('submitProduct - edit');
        return;
      }

      int countAssets = 0;
      // print('post product ddd' + images.length.toString());

      // images.forEach((asset) async {
      //   ByteData byteData = await asset.getByteData();
      //   List<int> imageData = byteData.buffer.asUint8List();
      //   // String base64Image;
      //   // base64Image = base64Encode(imageData);

      //   _files.add({
      //     "filename": asset.name,
      //     "data": base64Encode(imageData),
      //     "type": 'image/jpg'
      //   });

      //   countAssets++;

      //   if (countAssets == images.length) {
      //     print('uploading...');
      //     submitProduct();
      //   }
      // });

      submitProduct(context);
    }

    // setState(() {
    //   if (images.length == 0) {
    //     _dashedBoxColor = Colors.red;
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // });

    return;
  }

  @override
  void initState() {
    super.initState();

    setValues();

    // Get the location first then fetch the products
  }

  void setValues() {
    // Check if edit
    if (widget.mode == 'edit') {
      setState(() {
        _roundImage = DecorationImage(
            image: NetworkImage(widget.product!.imageUrl!),
            alignment: Alignment.bottomRight,
            fit: BoxFit.fill,
            scale: 0.1);
      });
      // _productNameController.text = widget.product!.name!;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Container dashedBox() => Container(
        height: 80,
        width: 80,
        padding: EdgeInsets.all(10),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(12),
          color: _dashedBoxColor!,
          dashPattern: [4, 4],
          child: Center(
              child: Icon(
            Icons.add,
            size: 50,
            color: _dashedBoxColor,
          )),
        ),
      );

  void validate() {
    setState(() {
      _enableButton = _qtyController.text.isNotEmpty;
    });
  }

  Widget contributionTotal() {
    return Container(
        height: 116,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 62,
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Contribution Qty'),
                      Text(
                        'P 100',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sub Total'),
                      Text(
                        'P 100',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            totalGreen('total'),
          ],
        ));
  }

  Widget totalGreen(String totalText, {Color? color}) {
    return Container(
      padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            upperCase(totalText),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'P 100',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      color: color != null ? color : greenColor,
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context,
          isMain: false,
          title: widget.mode == 'add' ? 'Add Product' : 'Edit Product'),
      backgroundColor: body_color,
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: ListView(children: [
              // Text('Upload Photo'),
              Text(
                _fileErrorMessage,
                style: TextStyle(color: Colors.red),
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      loadAssets();
                    },
                    child: addPhoto(_roundImage),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                  ),
                  Text(
                    'Take/Upload Product Photo',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
              (images.length > 0)
                  ? Container(
                      height: 100,
                      child: buildGridView(),
                    )
                  : Container(),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  initialValue: widget.product!.name.toString(),
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(RegExp(
                  //       '[a-zA-Z0-9. ]')), // with space. check after dot(.)
                  // ],
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: 'Product Name',
                    labelStyle: new TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      borderSide: BorderSide(
                        color: inputBorderColor,
                        //width: 2.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[100]!),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Product Name is required!';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  controller: _qtyController,
                  autofocus: true,
                  inputFormatters: [ThousandsFormatter()],
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.right,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: '1000',
                    hintStyle: new TextStyle(color: Colors.grey[300]),
                    labelText: 'Qty to Distribute',
                    labelStyle: new TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      borderSide: BorderSide(
                        color: inputBorderColor,
                        //width: 2.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[100]!),
                    ),
                  ),
                  onChanged: (val) {
                    validate();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Qty is required!';
                    }
                    if (value == '0') {
                      return 'Qty should be more than 0!';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                  padding: EdgeInsets.fromLTRB(0, 109, 0, 10),
                  child:
                      Text('Contribution Price', style: ThemeText.yellowLabel)),
              contributionTotal(),

              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 16.0),
                  child: iconActionButton(
                      context: context,
                      buttonColor: 'green',
                      // icon: Icon(Icons.close),
                      text: 'submit',
                      // order: order,
                      // orderCallback: rateOrder,
                      enable: _enableButton,
                      isLoading: false,
                      callback: contributeProduct)),
            ])),
      ),
    );
  }
}
