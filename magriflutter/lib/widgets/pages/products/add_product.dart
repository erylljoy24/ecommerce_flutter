import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:magri/models/category.dart';
import 'package:magri/models/product.dart';
import 'package:magri/services/location_service.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magri/Constants.dart' as Constants;
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:magri/google_map_location_picker/src/google_map_location_picker.dart';
// import 'package:magri/google_map_location_picker/src/model/location_result.dart';
// import 'package:place_picker/place_picker.dart';

import '../../../Constants.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class AddProduct extends StatefulWidget {
  final String mode;
  final Product? product;
  AddProduct({this.mode = 'add', this.product});
  @override
  State<StatefulWidget> createState() => new _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool _isLoading = false;
  double progress = 0.2;

  final _productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();
  final stocksController = TextEditingController();
  final _locationController = TextEditingController();

  FocusNode _focus = new FocusNode();

  DecorationImage? _roundImage;

  String? _productName;
  String? _description;
  String? _unit;
  String? _price;
  String? _stocks;
  double? _latitude;
  double? _longitude;
  String? _address;

  LatLng _initialCeneter = LatLng(14.5839333, 121.0500025);

  List<Category> _categories = [];

  List _files = [];

  bool _hasSelectedImages = true;

  //var _categories = ["New Patient", "I'm an Existing Patient"];
  String? _categoryId = "1";

  List<Asset> images = <Asset>[];
  String _error = 'No Error Dectected';

  String _fileErrorMessage = '';

  late File _image;
  final picker = ImagePicker();
  dynamic _pickImageError;
  bool isVideo = false;

  Color? _dashedBoxColor = Colors.grey[600];

  // Future<List<dynamic>?> fetchCategories() async {
  //   final SharedPreferences prefs = await _prefs;
  //   String? token = await prefs.getString('token');

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   print(Constants.categories);

  //   try {
  //     final url = Uri.parse(Constants.categories);

  //     var bearerToken = 'Bearer ' + token.toString();
  //     var result = await http.get(url, headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': bearerToken
  //     });

  //     Map<String, dynamic>? map = json.decode(result.body);
  //     print(Constants.categories + result.statusCode.toString());

  //     setState(() {
  //       _isLoading = false;
  //     });
  //     if (result.statusCode == 200) {
  //       return map!['data'];
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //     if (!mounted) {
  //       return null;
  //     }
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }

  //   return null;
  // }

  Widget buildGridView() {
    return GridView.count(
      crossAxisSpacing: 5,
      crossAxisCount: 4,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        print(asset.name);
        return showImage(asset, index);
        // return AssetThumb(
        //   asset: asset,
        //   width: 300,
        //   height: 300,
        // );
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
              print('xxx');

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
      // print('error===================' + error);
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
        //BottomSheetAction(title: const Text('Item 3'), onPressed: () {}),
      ],
      cancelAction: CancelAction(
          title: const Text(
              'Cancel')), // onPressed parameter is optional by default will dismiss the ActionSheet
    );
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

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

  Future submitProduct() async {
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('token');

    var bearerToken = 'Bearer ' + token.toString();
    var url = Uri.parse(Constants.postProduct);

    if (widget.mode == 'edit') {
      url = Uri.parse(
          Constants.postProduct + '/' + widget.product!.id! + '/update');
    }

    print(url.path);
    http
        .post(url,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': bearerToken
            },
            body: json.encode(<dynamic, dynamic>{
              "name": _productNameController.text,
              "category_id": _categoryId,
              "description": descriptionController.text,
              "unit": unitController.text,
              "price": priceController.text,
              "stocks": stocksController.text.replaceAll(',', ''),
              "latitude": _latitude,
              "longitude": _longitude,
              "address": _locationController.text,
              "mode": widget.mode,
              "files": _files
              // "files": [
              //   {
              //     "filename": asset.name,
              //     "data": base64Encode(imageData),
              //     "type": 'image/jpg'
              //   }
              // ]
            }))
        .then((res) async {
      print(res.statusCode);
      String? stringedJson = prefs.getString('drafts');
      List<dynamic> list = json.decode(stringedJson!);
      list.add(json.encode(<String, dynamic>{
        "name": _productNameController.text,
        "category_id": _categoryId,
        "description": descriptionController.text,
        "unit": unitController.text,
        "price": priceController.text,
        "stocks": stocksController.text.replaceAll(',', ''),
        "latitude": _latitude,
        "longitude": _longitude,
        "address": _locationController.text,
        "mode": widget.mode
        // "files": [
        //   {
        //     "filename": asset.name,
        //     "data": base64Encode(imageData),
        //     "type": 'image/jpg'
        //   }
        // ]
      }));
      await prefs.setString('drafts', json.encode(list));

      if (res.statusCode == 413) {
        //
        setState(() {
          _isLoading = false;
          _dashedBoxColor = Colors.red;
          _fileErrorMessage = 'Upload smaller file size';
        });
        print('upload smaller file size');

        return;
      }
      print('Done.');
      Navigator.pop(context, {"result": "success"});
      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      print(err);
    });
  }

  Future postProduct() async {
    print('post product');
    if (_formKey.currentState!.validate()) {
      // Process
      // print('post product valid');
      setState(() {
        _fileErrorMessage = '';
        _isLoading = true;
      });

      // If no images selected and update mode
      if (widget.mode == 'edit') {
        submitProduct();
        print('submitProduct - edit');
        return;
      }

      int countAssets = 0;
      // print('post product ddd' + images.length.toString());

      images.forEach((asset) async {
        ByteData byteData = await asset.getByteData();
        List<int> imageData = byteData.buffer.asUint8List();
        // String base64Image;
        // base64Image = base64Encode(imageData);

        _files.add({
          "filename": asset.name,
          "data": base64Encode(imageData),
          "type": 'image/jpg'
        });

        countAssets++;

        if (countAssets == images.length) {
          print('uploading...');
          submitProduct();
        }
      });
    }

    setState(() {
      if (images.length == 0) {
        _dashedBoxColor = Colors.red;
        setState(() {
          _isLoading = false;
        });
      }
    });

    return;
    //Uri uri = Uri.parse('http://localhost:7071/api/products');

    //print(productController.text);

    // // create multipart request
    // MultipartRequest request = http.MultipartRequest('POST', uri);

    // Map<String, String> headers = {
    //   //"Accept": "application/json",
    //   "Content-Type": "multipart/form-data; boundary=-----xxxxx",
    //   //"Authorization": "Bearer " + token
    // };

    // request.fields['name'] = 'Manga';
    // request.fields['description'] = 'Manga description';
  }

  // Future getImageGallery() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);

  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       print(_image.path);
  //       var image = Image.file(_image);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });

  //   Navigator.of(context).pop();
  // }



  @override
  void initState() {
    super.initState();

    setValues();
    _focus.addListener(_onFocusChange);

    fetch();

    // fetchCategories().then((dataItems) {
    //   setState(() {
    //     dataItems!.forEach((item) {
    //       _categories.add(Category.fromMap(item));
    //     });

    //     _isLoading = false;
    //   });
    // });

    // Start listening to changes.
    _productNameController.addListener(_setProductName);
    descriptionController.addListener(_setDescription);
    unitController.addListener(_setUnit);
    priceController.addListener(_setPrice);
    stocksController.addListener(_setStocks);

    // Get the location first then fetch the products
    _determinePosition().then((value) {});
  }

  void setValues() {
    // Check if edit
    if (widget.mode == 'edit') {
      setState(() {
        _categoryId = widget.product!.categoryId!.toString();
        _roundImage = DecorationImage(
            image: NetworkImage(widget.product!.imageUrl!),
            alignment: Alignment.bottomRight,
            fit: BoxFit.fill,
            scale: 0.1);
      });
      _productNameController.text = widget.product!.name!;
      descriptionController.text = widget.product!.description!;
      unitController.text = widget.product!.unit!;
      priceController.text = widget.product!.price;
      stocksController.text = widget.product!.stocks!;
      _latitude = widget.product!.latitude;
      _longitude = widget.product!.longitude;
      _address = widget.product!.address;
      _locationController.text = widget.product!.address!;
      if (_latitude != null && _latitude != null) {
        _initialCeneter = LatLng(_latitude!, _longitude!);
      }
    }
  }

  Future<void> fetch() async {
    await fetchCategories().then((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    descriptionController.dispose();
    unitController.dispose();
    priceController.dispose();
    stocksController.dispose();

    super.dispose();
  }

  // void _onFocusChange() async {
  //   // Open modal
  //   if (_focus.hasFocus) {
  //     // LocationResult result =
  //     //     await Navigator.of(context).push(MaterialPageRoute(
  //     //         builder: (context) => PlacePicker(
  //     //               GOOGLE_MAPS_API_KEY,
  //     //               displayLocation: LatLng(14.5839333, 121.0500025),
  //     //             )));

  //     // // Handle the result in your way
  //     // setState(() {
  //     //   _latitude = result.latLng!.latitude;
  //     //   _longitude = result.latLng!.longitude;
  //     //   _address = result.formattedAddress;

  //     //   _locationController.text = _address!;
  //     // });

  //     // print('latLng:' + result.latLng.toString());
  //     // print('address:' + result.formattedAddress!);

  //     // _focus.nextFocus();
  //   }
  //   debugPrint("Focus: " + _focus.hasFocus.toString());
  // }

  void _onFocusChange() async {
    // Open modal
    if (_focus.hasFocus) {
      LocationResult? result = await showLocationPicker(
          context, Constants.GOOGLE_MAPS_API_KEY,
          initialCenter: _initialCeneter,
          countries: ['PH'],
          myLocationButtonEnabled: true);

      // Handle the result in your way
      if (result != null) {
        setState(() {
          _latitude = result.latLng!.latitude;
          _longitude = result.latLng!.longitude;
          _address = result.address;

          _initialCeneter = LatLng(_latitude!, _longitude!);

          _locationController.text = _address!;
        });

        print('latLng:' + result.latLng.toString());
        print('address:' + result.address!);
      }

      _focus.nextFocus();
    }
    debugPrint("Focus: " + _focus.hasFocus.toString());
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<bool> _determinePosition() async {
    LatLng? target;
    try {
      target = await determinePosition();
    } catch (e) {
      target = null;
    }

    if (!mounted) {
      return false;
    }

    setState(() {
      if (target != null) {
        // Set current position of the app user
        setState(() {
          _initialCeneter = target!;
        });

        print('My latitude: ' + target.latitude.toString());
        print('My longitude: ' + target.longitude.toString());
      }
    });
    return true;
  }

  _setProductName() {
    setState(() {
      _productName = _productNameController.text;
    });
    //print("Second text field: ${productController.text}");
  }

  _setDescription() {
    setState(() {
      _description = descriptionController.text;
    });
  }

  _setUnit() {
    setState(() {
      _unit = unitController.text;
    });
  }

  _setPrice() {
    setState(() {
      _price = priceController.text;
    });
  }

  _setStocks() {
    setState(() {
      _stocks = stocksController.text;
    });
  }

  Widget textField(String labelText, [int? line]) {
    return TextFormField(
      maxLines: line,
      //keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        //hintText: "hint",
        labelText: labelText,
        labelStyle: new TextStyle(color: Colors.black),
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
    );
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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //final productController = TextEditingController();
    return Scaffold(
      // floatingActionButton: Padding(
      //     padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      //     child: SizedBox(
      //       height: 40.0,
      //       width: double.infinity,
      //       child: new RaisedButton(
      //         elevation: 3.0,
      //         shape: new RoundedRectangleBorder(
      //             borderRadius: new BorderRadius.circular(10.0)),
      //         color: Colors.green[700],
      //         child: new Text('Post Product',
      //             style: new TextStyle(fontSize: 14.0, color: Colors.white)),
      //         onPressed: () {
      //           // Post a product
      //           postProduct();
      //         },
      //       ),
      //     )),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // appBar: AppBar(
      //   backgroundColor: body_color,
      //   title: Text(
      //     'Add Product',
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   elevation: 0,
      //   leading: popArrow(context),
      //   bottomOpacity: 0.0,
      // ),
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

              // _showCircularProgress(),

              // Expanded(
              //   child: buildGridView(),
              // ),
              //_image == null ? Text('No image selected.') : Image.file(_image),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  controller: _productNameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(
                        '[a-zA-Z0-9. ]')), // with space. check after dot(.)
                  ],
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
                  padding: const EdgeInsets.fromLTRB(0, 12.0, 0.0, 0.0),
                  child: Container(
                      height: 45,
                      decoration: ShapeDecoration(
                        color: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          side:
                              BorderSide(width: 0.1, style: BorderStyle.solid),
                          //borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                      child: _isLoading
                          ? spin()
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: Text('Select Category'),
                                value: _categoryId,
                                isDense: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _categoryId = newValue;
                                    print(newValue);
                                  });
                                },
                                items: _categories.map((Category category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id.toString(),
                                    child: Text(
                                      '   ' + category.name!,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ))),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 3,
                  keyboardType: TextInputType.text,
                  controller: descriptionController,
                  autofocus: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(
                        '[a-zA-Z0-9!. ]')), // with space. check after dot(.)
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: "Product Description",
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
                      return 'Description is required!';
                    }

                    if (value.trim() == '') {
                      return 'Description is required!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new Flexible(
                          child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          controller: unitController,
                          autofocus: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                '[a-zA-Z0-9]')), // with space. check after dot(.)
                          ],
                          textInputAction: TextInputAction.next,
                          decoration: new InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelText: 'Unit of measurement per base price',
                            hintText: 'kg',
                            labelStyle: new TextStyle(color: Colors.grey),
                            hintStyle: new TextStyle(color: Colors.grey[300]),
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
                              return 'Unit is required!';
                            }
                            return null;
                          },
                        ),
                      )),
                      new Flexible(
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          controller: priceController,
                          autofocus: false,
                          inputFormatters: [
                            ThousandsFormatter(
                                allowFraction:
                                    true) // with space. check after dot(.)
                          ],
                          textInputAction: TextInputAction.next,
                          textAlign: TextAlign.right,
                          decoration: new InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelText: 'Base price (Php)',
                            labelStyle: new TextStyle(color: Colors.grey),
                            hintText: '1,000.00',
                            hintStyle: new TextStyle(color: Colors.grey[300]),
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
                              return 'Price is required!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ]),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
              //   child: textField('Email'),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  controller: stocksController,
                  autofocus: false,
                  inputFormatters: [ThousandsFormatter()],
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.right,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: '1000',
                    hintStyle: new TextStyle(color: Colors.grey[300]),
                    labelText: 'Qty in Stocks',
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
                      return 'Stocks is required!';
                    }
                    if (value == '0') {
                      return 'Stocks should be more than 0!';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  focusNode: _focus, //  This will open the address in map
                  maxLines: 3,
                  keyboardType: TextInputType.text,
                  controller: _locationController,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Mandaluyong City',
                    hintStyle: new TextStyle(color: Colors.grey[300]),
                    labelText: 'Location',
                    labelStyle: new TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      borderSide: BorderSide(
                        color: inputBorderColor,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[100]!),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Location is required!';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 16.0),
                  child: iconActionButton(
                      context: context,
                      buttonColor: 'green',
                      // icon: Icon(Icons.close),
                      text: 'submit',
                      // order: order,
                      // orderCallback: rateOrder,
                      isLoading: false,
                      callback: postProduct)),

              // Padding(
              //     padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 16.0),
              //     child: SizedBox(
              //       height: 40.0,
              //       width: double.infinity,
              //       child: new ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           elevation: 3.0,
              //           shape: new RoundedRectangleBorder(
              //               borderRadius: new BorderRadius.circular(10.0)),
              //           primary: Colors.green[700],
              //         ),
              //         child: new Text('Post Product',
              //             style: new TextStyle(
              //                 fontSize: 14.0, color: Colors.white)),
              //         onPressed: () {
              //           // Post a product
              //           postProduct();
              //         },
              //       ),
              //     ))

              // Positioned(
              //   child: Text('Post'),
              //   bottom: 10,
              //   right: 10,
              //   left: 10,
              // )
            ])),
      ),
    );
  }
}
