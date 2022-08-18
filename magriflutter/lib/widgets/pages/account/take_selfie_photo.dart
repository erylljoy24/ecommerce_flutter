import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:magri/models/address.dart';
import 'package:magri/models/barangay.dart';
import 'package:magri/models/changenotifiers/changenotifieraddress.dart';
import 'package:magri/models/city.dart';
import 'package:magri/models/province.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/modals/application_submitted_modal.dart';
import 'package:magri/widgets/pages/account/take_photo.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:magri/util/colors.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:phone_number/phone_number.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class TakeSelfiePhoto extends StatefulWidget {
  final User user;
  TakeSelfiePhoto(this.user);
  @override
  State<StatefulWidget> createState() => new _TakeSelfiePhotoState();
}

class _TakeSelfiePhotoState extends State<TakeSelfiePhoto>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double progress = 0.2;

  final picker = ImagePicker();

  late File _image;

  String? _idPhotoPath1;
  String? _idPhotoPath2;

  String? _phoneErrorMessage;

  Uint8List? _idPhotoFileByte1;
  Uint8List? _idPhotoFileByte2;

  List<Asset> _images = <Asset>[];

  bool _showCamera = true;

  bool _havePhoto = false;
  bool _haveSelfie = false;

  bool _showNextButton = false;

  bool _hasImage = false;

  String? _imagePath;

  DecorationImage? _roundImage1;
  DecorationImage? _roundImage2;
  DecorationImage? _selfieRoundImage;

  FocusNode _focus = new FocusNode();

  TextEditingController _regionController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  TextEditingController _streetAddress = new TextEditingController();
  TextEditingController _postalCodeController = new TextEditingController();

  List<Widget> list = [];

  TabController? _controller;

  List<Province> _provinces = getProvinces();
  List<City> _cities = [];

  String? _selectProvince = 'Select Province';
  String? _selectCity = '';
  String _selectDistrict = '';

  String _selectedAddress = 'Region/City/District*';

  // Disable tabbar bar
  List<bool> _isDisabled = [false, false, false];

  String _beingVerified =
      'Being verified shows that you are a legitimate buyer on Magri';

  @override
  void initState() {
    super.initState();

    currentFile('take_selfie_photo.dart');

    _focus.addListener(_onFocusChange);

    setState(() {
      list = [
        Tab(
          child: Text(
            _selectProvince!,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Tab(
          child: Text(
            _selectCity!,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Tab(
          child: Text(
            _selectDistrict,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ];
    });

    _controller = TabController(length: list.length, vsync: this);

    _controller!.addListener(() {
      print("Selected Index: " + _controller!.index.toString());
    });

    _nameController.addListener(() {
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setName(_nameController.text);
      print("Name value: " + _nameController.text);
    });

    _phoneNumberController.addListener(() {
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setPhoneNumber(_phoneNumberController.text);
      print("_phoneNumberController value: " + _phoneNumberController.text);
    });

    _streetAddress.addListener(() {
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setStreetAddress(_streetAddress.text);
      print("_streetAddress value: " + _streetAddress.text);
    });

    _postalCodeController.addListener(() {
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setPostalCode(_postalCodeController.text);
      print("_postalCodeController value: " + _postalCodeController.text);
    });

    if (widget.user.type == User.SELLER_TYPE) {
      setState(() {
        _beingVerified =
            'Being verified allows you to sell on Magri, just enter in the requirements below:';
      });
    }

    getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFocusChange() {
    // Open modal
    if (_focus.hasFocus) {
      // provinceCityModal(context, address: _address);
      provinceCityModal(context);

      _focus.nextFocus();
    }
    debugPrint("Focus: " + _focus.hasFocus.toString());
  }

  void provinceCityModal(BuildContext context, {Address? address}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          var address = context.watch<ChangeNotifierAddress>();
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: 400,
                padding: EdgeInsets.all(20.0),
                //color: Colors.grey[100],
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 2,
                              child: TabBar(
                                labelColor: Colors.black,
                                indicatorColor: Colors.yellow,
                                isScrollable: true,
                                indicatorSize: TabBarIndicatorSize.label,
                                onTap: (index) {
                                  // Should not used it as it only called when tab options are clicked,
                                  // not when user swapped
                                },
                                controller: _controller,
                                tabs: list,
                              )),
                          new GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                  padding: EdgeInsets.only(left: 18),
                                  child: Icon(Icons.close))),
                        ],
                      ),
                      Expanded(
                          child: Container(
                              height: 200,
                              child: TabBarView(
                                  controller: _controller,
                                  children: [
                                    ListView(
                                      children:
                                          _provinces.map((Province province) {
                                        return ListTile(
                                            title: Text(province.name!),
                                            onTap: () async {
                                              Provider.of<ChangeNotifierAddress>(
                                                      context,
                                                      listen: false)
                                                  .setProvinceId(province.id);
                                              Provider.of<ChangeNotifierAddress>(
                                                      context,
                                                      listen: false)
                                                  .setProvinceName(
                                                      province.name);

                                              Provider.of<ChangeNotifierAddress>(
                                                      context,
                                                      listen: false)
                                                  .setCityId(null);

                                              await setCities(province);
                                              setState(() {
                                                _isDisabled[1] = false;

                                                _selectProvince = province.name;
                                                _selectCity = 'Select City';
                                                _selectDistrict = '';
                                                list[0] =
                                                    Tab(text: _selectProvince);
                                                list[1] = Tab(
                                                  child: Text(
                                                    _selectCity!,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                );
                                                list[2] = Tab(
                                                  child: Text(
                                                    _selectDistrict,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                );
                                                _controller!.index =
                                                    1; // select city
                                              });
                                            });
                                      }).toList(),
                                    ),
                                    address.cityIsLoading
                                        ? spin()
                                        : ListView(
                                            children: address
                                                .getCities()
                                                .map((City city) {
                                              //_cities.map((City city) {
                                              //print('city');
                                              // if (address.getCities().last.id ==
                                              //     city.id) {
                                              //   Provider.of<ChangeNotifierAddress>(
                                              //           context,
                                              //           listen: false)
                                              //       .setCityNotLoading();
                                              // }

                                              return ListTile(
                                                  title: Text(city.name!),
                                                  onTap: () {
                                                    Provider.of<ChangeNotifierAddress>(
                                                            context,
                                                            listen: false)
                                                        .setCityId(city.id);
                                                    Provider.of<ChangeNotifierAddress>(
                                                            context,
                                                            listen: false)
                                                        .setCityName(city.name);

                                                    Provider.of<ChangeNotifierAddress>(
                                                            context,
                                                            listen: false)
                                                        .setBarangayId(null);

                                                    setBarangays(city);
                                                    setState(() {
                                                      _isDisabled[2] = false;
                                                      _controller!.index = 2;
                                                      _selectCity = city.name;
                                                      _selectDistrict =
                                                          'Select District';
                                                      list[1] = Tab(
                                                        child: Text(
                                                          _selectCity!,
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      );
                                                      list[2] = Tab(
                                                        child: Text(
                                                          _selectDistrict,
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      );
                                                    });
                                                  });
                                            }).toList(),
                                          ),
                                    ListView(
                                      children: address
                                          .getBarangays()
                                          .map((Barangay barangay) {
                                        return ListTile(
                                            title: Text(barangay.name!),
                                            onTap: () {
                                              Provider.of<ChangeNotifierAddress>(
                                                      context,
                                                      listen: false)
                                                  .setBarangayId(barangay.id);
                                              Provider.of<ChangeNotifierAddress>(
                                                      context,
                                                      listen: false)
                                                  .setBarangayName(
                                                      barangay.name);
                                              setState(() {
                                                _selectedAddress =
                                                    _selectProvince! +
                                                        '/' +
                                                        _selectCity! +
                                                        '/' +
                                                        barangay.name!;
                                              });
                                              Navigator.pop(context, {
                                                "result": "success",
                                                "provice_id": 1
                                              });
                                            });
                                      }).toList(),
                                    ),
                                  ]))),
                    ],
                  ),
                ),
              ));
        });
      },
    );
  }

  void setBarangays(City city) {
    setState(() {
      fetchBarangays(city.id).then((dataItems) {
        Provider.of<ChangeNotifierAddress>(context, listen: false)
            .clearBarangays();
        if (dataItems != null) {
          dataItems.forEach((item) {
            Provider.of<ChangeNotifierAddress>(context, listen: false)
                .addBarangay(Barangay.fromMap(item));
            //print(Barangay.fromMap(item).name);
          });
        }
      });
    });
  }

  setCities(Province province) async {
    Provider.of<ChangeNotifierAddress>(context, listen: false).clearCities();
    setState(() {
      _cities.clear();
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setCities(_cities);
      fetchCities(province.id).then((dataItems) {
        if (dataItems != null) {
          dataItems.forEach((item) {
            Provider.of<ChangeNotifierAddress>(context, listen: false)
                .addCity(City.fromMap(item));
          });
          Provider.of<ChangeNotifierAddress>(context, listen: false)
              .setCityNotLoading();
        }
      });
    });
  }

  final _formKey = GlobalKey<FormState>();
  Widget addressForm() {
    // If no images yet
    if (_havePhoto == false || _haveSelfie == false) {
      return Container();
    }
    return Container(
        padding: EdgeInsets.only(left: 29, right: 29),
        // color: Colors.red,
        height: 398,
        child: Form(
            key: _formKey,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  //keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.words,
                  controller: _nameController,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp('[a-zA-Z. ]')), // with space. check after dot(.)
                    // FilteringTextInputFormatter.allow(RegExp(
                    //     '[a-zA-Z0-9. ]')), // with space. check after dot(.)
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    //hintText: 'Name',
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: "Full Name \*",
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
                      return 'Name is required!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  controller: _phoneNumberController,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    prefix: Text(
                      '+63 | ',
                      style: TextStyle(color: Colors.green[800]),
                    ),
                    errorText: _phoneErrorMessage,
                    //hintText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.grey[100],
                    // labelText: "Name \*",
                    labelText: "Phone Number \*",
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
                  onChanged: (value) {
                    validatePhone();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Phone is required!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  //keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.words,
                  controller: _streetAddress,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(
                        '[a-zA-Z0-9. ]')), // with space. check after dot(.)
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    // hintText: 'House Number, Building, Street Name',
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: "House Number, Building, Street Name \*",
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
                      return 'Address is required!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  focusNode: _focus,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.words,
                  controller: _regionController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    hintText: _selectedAddress,
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: _selectedAddress,
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
                      return 'Name is required!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  // textCapitalization: TextCapitalization.words,
                  controller: _postalCodeController,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    // labelText: "Name \*",
                    labelText: "Postal Code \*",
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
                      return 'Postal Code is required!';
                    }
                    return null;
                  },
                ),
              ),
              // addAddressButton(),
            ])));
  }

  void getUser() async {
    final SharedPreferences prefs = await _prefs;

    String? _currentUserId = await prefs.getString('userId');

    setState(() {
      _currentUserId = _currentUserId;
    });
  }

  void productCallback(BuildContext? context, Product? product) {
    print('callback view product' + product!.qty.toString());
    if (product.qty > 0) {
      Navigator.of(context!).push(MaterialPageRoute(
          builder: (context) => ConfirmOrder(product: product)));
    }
  }

  void callback(BuildContext? context) {
    // if (product.qty > 0) {
    // Navigator.of(context!).push(MaterialPageRoute(
    //     builder: (context) => ConfirmOrder(product: product)));
    // // }
  }

  Future<void> loadAssets() async {
    setState(() {
      _roundImage1 = null;
      _havePhoto = false;
      _images = [];
    });
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        selectedAssets: _images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "MAgri App",
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
      _images = resultList;
    });

    if (_images.length > 0) {
      Asset asset = _images[0];
      asset.getByteData().then((byteData) {
        List<int> imageData = byteData.buffer.asUint8List();

        setState(() {
          print('load');
          _showCamera = false;
          _havePhoto = true;
          _roundImage1 = DecorationImage(
              image: MemoryImage(imageData as Uint8List),
              alignment: Alignment.bottomRight,
              fit: BoxFit.fill,
              scale: 0.1);
        });
      });
    }

    return null;
  }

  _navigateTakePhoto(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TakePhoto()),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success
        // Image.file(File(result['imagePath']))
        setState(() {
          _hasImage = true;
          _haveSelfie = true;
          _imagePath = result['imagePath']; //  from camera
          _readFileByte(_imagePath!).then((bytesData) async {
            _selfieRoundImage = DecorationImage(
                image: MemoryImage(bytesData as Uint8List),
                alignment: Alignment.bottomRight,
                fit: BoxFit.fill,
                scale: 0.1);
          });
        });
        print(result['imagePath']);
      }
    }
  }

  Future<Uint8List?> _readFileByte(String filePath) async {
    Uri fileUri = Uri.parse(filePath);
    File file = new File.fromUri(fileUri);
    Uint8List? bytes;
    await file.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }

  dynamic storeAddress(Address address, [int? orderId]) async {
    var stored = await storeNewAddress(address, orderId);

    return stored;
    // if (isStored) {
    //   // address.province = address.province;
    //   // address.address = '';
    //   // print(address.barangay);
    // }
  }

  Widget nextButton() {
    // If no images yet
    if (_havePhoto == false || _haveSelfie == false) {
      return Container();
    }

    return iconActionButton(
        context: context,
        buttonColor: 'green',
        // icon: Icon(Icons.close),
        text: 'submit',
        // order: order,
        // orderCallback: rateOrder,
        isLoading: _isLoading,
        callback: submitId);
  }

  String? validatePhone() {
    setState(() {
      _phoneErrorMessage = null;
    });

    String? message;

    PhoneNumberUtil.isValidPhoneNumber(
            phoneNumber: '+63' + _phoneNumberController.text, isoCode: 'PH')
        .then((isValid) {
      if (isValid == false) {
        setState(() {
          _phoneErrorMessage = 'Invalid Phone Number!';
        });
        message = 'Invalid Phone Number!';
      }
    });

    return message;
  }

  // String? validatePhone() {
  //   setState(() {
  //     _phoneErrorMessage = null;
  //   });

  //   String? message;

  //   PhoneNumberUtil plugin = PhoneNumberUtil();
  //   RegionInfo region = RegionInfo(name: 'PH', code: 'US', prefix: 63);

  //   String springFieldUSASimple = '+63' + _phoneNumberController.text;
  //   plugin.validate(springFieldUSASimple, region.code).then((isValid) {
  //     if (isValid == false) {
  //       setState(() {
  //         _phoneErrorMessage = 'Invalid Phone Number!';
  //       });
  //       message = 'Invalid Phone Number!';
  //     }
  //   });

  //   return message;
  // }

  void submitId() async {
    setState(() {
      _isLoading = true;
    });
    validatePhone();
    dynamic address =
        Provider.of<ChangeNotifierAddress>(context, listen: false).getAddress;

    if (address['name'] == '' ||
        address['phone'] == '' ||
        address['street_address'] == '' ||
        address['postal_code'] == '' ||
        address['province_id'] == '' ||
        address['city_id'] == null ||
        address['barangay_id'] == null) {
      print('No');
      print(address['province_id']);
      print(address['city_id']);
      print(address['barangay_id']);

      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
          msg: 'Please enter required fields!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      setState(() {
        // _proceedIsLoading = true;
      });
      print('proceed');
      // var stored = await storeNewAddress(address);

      await storeNewAddress(
        Address(
          name: address['name'],
          phone: address['phone'],
          streetAddress: address['street_address'],
          postalCode: address['postal_code'],
          provinceId: address['province_id'],
          cityId: address['city_id'],
          barangayId: address['barangay_id'],
          province: address['province_name'],
          city: address['city_name'],
          barangay: address['barangay_name'],
          isDefault: false,
        ),
      );

      // print(' id:' + storedAddress['id'].toString());
    }

    var id_image1;

    List<int> imageData1 = _idPhotoFileByte1!;

    id_image1 = {
      "filename": 'id_image.jpg',
      "data": base64Encode(imageData1),
      "type": 'image/jpg'
    };

    var id_image2;

    if (_idPhotoFileByte2 != null) {
      List<int> imageData2 = _idPhotoFileByte2!;

      id_image2 = {
        "filename": 'id_image2.jpg',
        "data": base64Encode(imageData2),
        "type": 'image/jpg'
      };
    }

    var selfieImage;

    Uint8List? fileByte;

    String imagePath = _imagePath!;
    _readFileByte(imagePath).then((bytesData) async {
      fileByte = bytesData;

      selfieImage = {
        "filename": 'selfie_id_image.jpg',
        "data": base64Encode(fileByte!),
        "type": 'image/jpg'
      };

      final SharedPreferences prefs = await _prefs;
      String? token = await prefs.getString('token');
      var bearerToken = 'Bearer ' + token.toString();

      final url = Uri.parse(Constants.apiVerify);

      // If the form is valid, display a Snackbar.
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': bearerToken
          },
          body: json.encode(<dynamic, dynamic>{
            "id_image": id_image1,
            "id_image2": id_image2,
            "selfie_image": selfieImage,
          }));

      if (result.statusCode != 200) {
        print('error');
        print(result.body);

        // Show message then pop
        // Map<String, dynamic> map = json.decode(result.body);
        // setState(() {
        //   _emailErrorMessage = map['error'];
        // });
      } else {
        print(result.statusCode);
        Map<String, dynamic>? map = json.decode(result.body);
        // map['token'];
        print(result.body);

        applicationSubmittedModal(context);

        setState(() {
          _isLoading = false;
        });

        // AwesomeDialog(
        //     context: context,
        //     animType: AnimType.LEFTSLIDE,
        //     headerAnimationLoop: false,
        //     dialogType: DialogType.SUCCES,
        //     title: 'Success',
        //     desc: 'Details has been sent!',
        //     btnOkOnPress: () {
        //       debugPrint('OnClcik');
        //     },
        //     btnOkIcon: Icons.check_circle,
        //     onDissmissCallback: (type) {
        //       debugPrint('Dialog Dismiss from callback');
        //       // Navigator.pop(context);
        //     })
        //   ..show();
      }
    });

    // Navigator.pop(context);
  }

  void selectAction(int idNumber) {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Actions'),
      actions: <BottomSheetAction>[
        BottomSheetAction(
            title: const Text('Take Photo'),
            onPressed: () {
              getImage(ImageSource.camera, idNumber);
            }),
        BottomSheetAction(
            title: const Text('Photo Library'),
            onPressed: () {
              getImage(ImageSource.gallery, idNumber);
              // loadAssets();
            }),
      ],
      cancelAction: CancelAction(
          title: const Text(
              'Cancel')), // onPressed parameter is optional by default will dismiss the ActionSheet
    );
  }

  Future getImage(ImageSource source, int idNumber) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);

        if (idNumber == 1) {
          _idPhotoPath1 = _image.path;
          _idPhotoFileByte1 = bytes;

          _roundImage1 = DecorationImage(
              image: MemoryImage(bytes),
              alignment: Alignment.bottomRight,
              fit: BoxFit.fill,
              scale: 0.1);
        }

        if (idNumber == 2) {
          _idPhotoPath2 = _image.path;
          _idPhotoFileByte2 = bytes;
          _roundImage2 = DecorationImage(
              image: MemoryImage(bytes),
              alignment: Alignment.bottomRight,
              fit: BoxFit.fill,
              scale: 0.1);
        }

        // Check images
        if (widget.user.type == User.SELLER_TYPE) {
          if (_idPhotoPath1 != null && _idPhotoPath2 != null) {
            setState(() {
              _havePhoto = true;
            });
          }
        } else {
          if (_idPhotoPath1 != null) {
            setState(() {
              _havePhoto = true;
            });
          }
        }

        print(_image.path);
        // var image = Image.file(_image);
        //images.add(_image);
      } else {
        print('No image selected.');
      }
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context,
          isMain: false, title: 'Take Selfie / ID photo'),
      backgroundColor: body_color,
      body: new Container(
        child: ListView(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 20,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/verify_icon.png',
                    height: 103,
                    width: 84,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 20,
                ),
                child: Text(
                  'GET VERIFIED!',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              // GestureDetector(
              //   child: Text('Show pop'),
              //   onTap: () async {
              //     final result = await applicationSubmittedModal(context);
              //     print(result);
              //   },
              // ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                child: SizedBox(
                  width: 290,
                  child: Text(_beingVerified),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 29,
              top: 20,
            ),
            child: Text(
              'Verification Requirements',
              style: TextStyle(fontSize: 22),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                child: Center(
                  child: new GestureDetector(
                      onTap: () {
                        // Add image
                        // loadAssets();
                        selectAction(1);
                      },
                      child: addPhoto(_roundImage1)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              new GestureDetector(
                onTap: () {
                  // Add image
                  // loadAssets();
                  selectAction(1);
                },
                child: Text(
                  'Take/Upload ID Photo (1)',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          widget.user.type == User.SELLER_TYPE
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                      child: Center(
                        child: new GestureDetector(
                            onTap: () {
                              // Add image
                              // loadAssets();
                              //getImage(ImageSource.gallery);
                              selectAction(2);
                            },
                            child: addPhoto(_roundImage2)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                    ),
                    new GestureDetector(
                      onTap: () {
                        // Add image
                        // loadAssets();
                        selectAction(2);
                      },
                      child: Text(
                        'Take/Upload ID Photo (2)',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : Container(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                child: Center(
                  child: new GestureDetector(
                      onTap: () {
                        // Add image
                        _navigateTakePhoto(context);
                      },
                      child: addPhoto(_selfieRoundImage)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Text(
                'Take Selfie',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          addressForm(),

          Padding(
              padding: EdgeInsets.only(left: 29, right: 29),
              child: _isLoading ? spin() : nextButton()),
          //
          Padding(padding: EdgeInsets.only(bottom: 130)),
        ]),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: nextButton(),
    );
  }
}
