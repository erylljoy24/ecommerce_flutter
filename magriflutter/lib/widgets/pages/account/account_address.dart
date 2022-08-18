import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/addressController.dart';
import 'package:magri/models/address.dart';
import 'package:magri/models/barangay.dart';
import 'package:magri/models/changenotifiers/changenotifieraddress.dart';
import 'package:magri/models/city.dart';
import 'package:magri/models/province.dart';
import 'package:magri/models/user.dart';
import 'package:magri/services/base_client.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:provider/provider.dart';

class AccountAddress extends StatefulWidget {
  final User? user;
  final String? method;
  AccountAddress({this.user, this.method});

  @override
  State<StatefulWidget> createState() => _AccountAddressState();
}

class _AccountAddressState extends State<AccountAddress>
    with SingleTickerProviderStateMixin {
  bool _hasAddress = false;
  bool _isLoadingCities = false;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  bool _updateAddress = false;

  int? _addressId;
  int? _addressIdIndex;

  bool _defaultShippingAddress = false;

  List<Address> _addresses = [];

  FocusNode _focus = new FocusNode();

  final AddressController userController = Get.put(AddressController());

  TextEditingController _regionController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  TextEditingController _streetAddressController = new TextEditingController();
  TextEditingController _postalCodeController = new TextEditingController();

  bool _showCreateForm = false;

  List<Province> _provinces = getProvinces();
  List<City> _cities = [];

  String? _selectProvince = 'Select Province';
  String? _selectCity = '';
  String _selectDistrict = '';

  String _selectedAddress = 'Region/City/District*';

  String _buttonLabel = 'Add Address';

  // Disable tabbar bar
  List<bool> _isDisabled = [false, false, false];

  List<Widget> list = [];

  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);

    print('account_address.dart');

    fetchAddress();

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

    _streetAddressController.addListener(() {
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setStreetAddress(_streetAddressController.text);
      print("_streetAddress value: " + _streetAddressController.text);
    });

    _postalCodeController.addListener(() {
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setPostalCode(_postalCodeController.text);
      print("_postalCodeController value: " + _postalCodeController.text);
    });

    // Disable a tab for example no province selected yet
    // _controller.addListener(onTapTab);
  }

  // onTapTab() {
  //   if (_isDisabled[_controller.index]) {
  //     int index = _controller.previousIndex;
  //     setState(() {
  //       _controller.index = index;
  //     });
  //   }
  // }

  void _onFocusChange() {
    // Open modal
    if (_focus.hasFocus) {
      // provinceCityModal(context, address: _address);
      provinceCityModal(context);

      _focus.nextFocus();
    }
    debugPrint("Focus: " + _focus.hasFocus.toString());
  }

  void fetchAddress() {
    setState(() {
      _isLoading = true;
    });
    BaseClient().get('/addresses').then((dataItems) {
      setState(() {
        if (dataItems != null) {
          _addresses.clear();
          dataItems.forEach((item) {
            _addresses.add(Address.fromMap(item));
          });
        }
        _isLoading = false;
      });
    });
  }

  setCities(Province province) async {
    // Provider.of<ChangeNotifierAddress>(context, listen: false).setCityLoading();
    Provider.of<ChangeNotifierAddress>(context, listen: false).clearCities();
    setState(() {
      _cities.clear();
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setCities(_cities);
      fetchCities(province.id).then((dataItems) {
        if (dataItems != null) {
          dataItems.forEach((item) {
            setState(() {
              _cities.add(City.fromMap(item));
            });

            // Provider.of<ChangeNotifierAddress>(context, listen: false)
            //     .addCity(City.fromMap(item));
            // print(City.fromMap(item).name);
          });
          Provider.of<ChangeNotifierAddress>(context, listen: false)
              .setCities(_cities);
          Provider.of<ChangeNotifierAddress>(context, listen: false)
              .setCityNotLoading();
        }
      });
    });
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

                                              print(city.name! + '+');

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

  void storeAddress(Address address, {int? orderId, bool? isUpdate}) async {
    if (isUpdate!) {
      // Update
      address.id = _addressId;
      var update = await updateAddress(address);
      Address updatedAddress = Address.fromMap(update);
      setState(() {
        _showCreateForm = false;
        _isButtonLoading = false;
        _addresses[_addressIdIndex!] = updatedAddress;
      });
      fetchAddress();
    } else {
      var isStored = await storeNewAddress(address, orderId);
      if (isStored != 0) {
        // address.province = address.province;
        // address.address = '';
        // print(address.barangay);
        address.id = isStored['id'];

        setState(() {
          _addresses.add(address);
          // Hide the form
          _showCreateForm = false;
          _isButtonLoading = false;
        });
      }
      fetchAddress();
    }
  }

  void addUpdateAddress() {
    setState(() {
      _isButtonLoading = true;
    });
    dynamic address =
        Provider.of<ChangeNotifierAddress>(context, listen: false).getAddress;

    // if (widget.paymentMethod == 'wallet') {
    //   if (double.parse(walletAmount) <
    //       double.parse(widget.orderItem.total)) {
    //     // print('cant process');

    //     Fluttertoast.showToast(
    //         msg: 'Your wallet amount is not enough!',
    //         toastLength: Toast.LENGTH_LONG,
    //         gravity: ToastGravity.BOTTOM,
    //         timeInSecForIosWeb: 2,
    //         backgroundColor: Colors.red,
    //         textColor: Colors.white,
    //         fontSize: 16.0);
    //     return;
    //   }
    // }

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

      Fluttertoast.showToast(
          msg: 'Please enter required fields!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _isButtonLoading = false;
      });
    } else {
      setState(() {
        // _proceedIsLoading = true;
      });
      print('proceed');
      storeAddress(
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
            isDefault: _defaultShippingAddress,
          ),
          isUpdate: _updateAddress);
    }

    print(address['name']);
  }

  Widget addAddressButton() {
    return _isButtonLoading
        ? spin()
        : Padding(
            padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
            child: SizedBox(
                height: 40.0,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        primary: Colors.grey[700],
                      ),
                      child: new Text('Cancel',
                          style: new TextStyle(
                              fontSize: 14.0, color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          _showCreateForm = false;
                          _isButtonLoading = false;
                        });
                      },
                    ),
                    new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        primary: Colors.green[700],
                      ),
                      child: new Text(_buttonLabel,
                          style: new TextStyle(
                              fontSize: 14.0, color: Colors.white)),
                      onPressed: () {
                        addUpdateAddress();
                      },
                    )
                  ],
                )));
  }

  final _formKey = GlobalKey<FormState>();
  Widget addressForm() {
    return Container(
        // color: Colors.red,
        height: 460,
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
                    FilteringTextInputFormatter.allow(RegExp(
                        '[a-zA-Z0-9. ]')), // with space. check after dot(.)
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    prefix: Text(
                      '+63 | ',
                      style: TextStyle(color: Colors.green[800]),
                    ),
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
                  controller: _streetAddressController,
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
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16.0, 0.0, 0.0),
                  child: SizedBox(
                      height: 40.0,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Default Shipping Address'),
                          Padding(padding: EdgeInsets.only(bottom: 2)),
                          Row(
                            children: [
                              Text('Yes'),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _defaultShippingAddress = true;
                                    });
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: _defaultShippingAddress
                                          ? Colors.green[700]
                                          : Colors.grey[400],
                                    ),
                                  )),
                              Padding(padding: EdgeInsets.only(right: 20)),
                              Text('No'),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _defaultShippingAddress = false;
                                    });
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: !_defaultShippingAddress
                                          ? Colors.green[700]
                                          : Colors.grey[400],
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ))),
              addAddressButton(),
            ])));
  }

  void addressEdit(Address address, int index) {
    setState(() {
      _addressId = address.id;
      _addressIdIndex = index;
      _nameController.text = address.name!;
      _phoneNumberController.text = address.phone!;
      _streetAddressController.text = address.streetAddress!;
      _selectedAddress =
          address.province! + '/' + address.city! + '/' + address.barangay!;
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setProvinceId(address.provinceId);
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setCityId(address.cityId);
      Provider.of<ChangeNotifierAddress>(context, listen: false)
          .setBarangayId(address.barangayId);
      _postalCodeController.text = address.streetAddress!;

      _defaultShippingAddress = address.isDefault!;
      _updateAddress = true;
      _showCreateForm = true;
      _buttonLabel = 'Update Address';
    });
  }

  Widget addressData(Address address, int index) {
    return GestureDetector(
        onTap: () {
          // Check for method. If could be select address or edit address
          if (widget.method == 'select-address') {
            Navigator.pop(context, {"result": "success", "address": address});
          } else {
            // Edit
            // addressEdit(address, index);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      address.name!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    Text(address.phone!, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      addressEdit(address, index);
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(color: Colors.green[700]),
                    ))
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: Text(address.streetAddress! +
                    ', ' +
                    address.province! +
                    ', ' +
                    address.city! +
                    ', ' +
                    address.barangay! +
                    ' ' +
                    address.postalCode!)),
            address.isDefault!
                ? SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Text(
                      'Default shipping and billing address',
                      style: TextStyle(color: Colors.red),
                    ))
                : Text('')
          ],
        ));
  }

  Widget addressList() {
    if (_showCreateForm) {
      return Container();
    }
    return Expanded(
        child: ListView.separated(
      itemCount: _addresses.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        return addressData(_addresses[index], index);
      },
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarTopWithBack(context, isMain: false, title: 'My Address'),
        backgroundColor: body_color,
        body: new Container(
            // height: 260,
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              _showCreateForm
                  ? addressForm()
                  : Container(
                      height: 50,
                      // color: Colors.red,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCreateForm = true;
                            _updateAddress = false;
                            _addressId = null;
                            _nameController.text = '';
                            _phoneNumberController.text = '';
                            _streetAddressController.text = '';
                            _selectedAddress = 'Region/City/District*';
                            // Provider.of<ChangeNotifierAddress>(context,
                            //         listen: false)
                            //     .setProvinceId(address.provinceId);
                            // Provider.of<ChangeNotifierAddress>(context,
                            //         listen: false)
                            //     .setCityId(address.cityId);
                            // Provider.of<ChangeNotifierAddress>(context,
                            //         listen: false)
                            //     .setBarangayId(address.barangayId);
                            _postalCodeController.text = '';
                          });
                        },
                        child: Container(
                            height: 70,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.green)),
                            child: Center(child: Text('Create Address'))),
                      ),
                    ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              // _showCreateForm
              _isLoading ? spin() : addressList(),
            ])));
  }
}
