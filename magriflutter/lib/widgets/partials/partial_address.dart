import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:magri/models/address.dart';
import 'package:magri/models/barangay.dart';
import 'package:magri/models/changenotifiers/changenotifieraddress.dart';
import 'package:magri/models/city.dart';
import 'package:magri/models/province.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:magri/widgets/modals/province_city_modal.dart';
import 'package:provider/provider.dart';

class PartialAddress extends StatefulWidget {
  final User? user;
  PartialAddress({this.user});

  @override
  _PartialAddressState createState() => _PartialAddressState();
}

class _PartialAddressState extends State<PartialAddress>
    with SingleTickerProviderStateMixin {
  bool _hasAddress = false;
  bool _isLoadingCities = false;
  Address _address = Address(
      name: 'Manny',
      phone: '12222',
      address: 'Uni1',
      barangay: 'Pinag',
      city: 'Pila',
      province: 'Lag');

  FocusNode _focus = new FocusNode();

  TextEditingController _regionController = new TextEditingController();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  TextEditingController _streetAddress = new TextEditingController();

  List<Province> _provinces = getProvinces();
  List<City> _cities = [];

  String? _selectProvince = 'Select Province';
  String? _selectCity = '';
  String _selectDistrict = '';

  String _selectedAddress = 'Region/City/District';

  // Disable tabbar bar
  List<bool> _isDisabled = [false, false, false];

  List<Widget> list = [];

  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);

    print('set');

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
      provinceCityModal(context, _address);

      _focus.nextFocus();
    }
    debugPrint("Focus: " + _focus.hasFocus.toString());
  }

  void setCities(Province province) {
    // Provider.of<ChangeNotifierAddress>(context, listen: false).setCityLoading();
    Provider.of<ChangeNotifierAddress>(context, listen: false).clearCities();
    setState(() {
      fetchCities(province.id).then((dataItems) {
        _cities.clear();

        if (dataItems != null) {
          dataItems.forEach((item) {
            //_cities.add(City.fromMap(item));
            Provider.of<ChangeNotifierAddress>(context, listen: false)
                .addCity(City.fromMap(item));
            print(City.fromMap(item).name);
          });
          // Provider.of<ChangeNotifierAddress>(context, listen: false)
          //     .setCityNotLoading();
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

  void provinceCityModal(BuildContext context, Address address) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          // final quantityController =
          //     TextEditingController(text: quantity.toString());
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
                                            onTap: () {
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

                                              // Clear cities
                                              setState(() {
                                                _cities.clear();
                                              });
                                              setCities(province);
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
                                                // sleep(
                                                //     const Duration(seconds: 1));
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
                      // Spacer(),
                      // Text('Quantity'),
                      // Spacer(),
                    ],
                  ),
                ),
              ));
        });
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    if (!_hasAddress) {
      return new Container(
          height: 260,
          //padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: ListView(children: [
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
                      labelText: "Name \*",
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
                      //hintText: 'Phone Number',
                      filled: true,
                      fillColor: Colors.grey[100],
                      // labelText: "Name \*",
                      labelText: "Phone Number \*",
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
                    //keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.words,
                    controller: _regionController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: new InputDecoration(
                      hintText: _selectedAddress,
                      filled: true,
                      fillColor: Colors.grey[100],
                      //labelText: 'Product Name',
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name is required!';
                      }
                      return null;
                    },
                  ),
                ),
              ])));
    }
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_address.name!),
                Text(_address.phone!),
                Text(_address.address!),
                Text(_address.barangay!),
                Text(_address.city!),
                Text(_address.province!),
              ]),
          GestureDetector(
            child: Icon(Icons.edit),
            onTap: () {
              provinceCityModal(context, _address);
            },
          )
        ]);
  }
}
