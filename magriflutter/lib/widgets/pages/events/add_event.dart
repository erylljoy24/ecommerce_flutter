import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/Constants.dart' as Constants;
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_map_location_picker/google_map_location_picker.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class AddEvent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  bool _isLoading = false;
  double progress = 0.2;

  final eventNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final quotaController = TextEditingController();
  // final priceController = TextEditingController();
  // final stocksController = TextEditingController();
  final _locationController = TextEditingController();

  FocusNode _focus = new FocusNode();

  double? _latitude;
  double? _longitude;
  String? _address;

  List<Asset> images = <Asset>[];

  Future createEvent() async {
    if (_formKey.currentState!.validate()) {
      // Process
      setState(() {
        //_fileErrorMessage = '';
      });
      setState(() {
        _isLoading = true;
      });

      final SharedPreferences prefs = await _prefs;
      String? token = await prefs.getString('token');

      var bearerToken = 'Bearer ' + token.toString();

      final url = Uri.parse(Constants.postEvents);

      http
          .post(url,
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization': bearerToken
              },
              body: json.encode(<dynamic, dynamic>{
                "name": eventNameController.text,
                "quota": quotaController.text,
                "amount": quotaController.text,
                "address": _locationController.text,
                "latitude": _latitude,
                "longitude": _longitude
              }))
          .then((res) {
        print(res.statusCode);
        if (res.statusCode == 413) {
          //
          setState(() {
            _isLoading = false;
            // _dashedBoxColor = Colors.red;
            // _fileErrorMessage = 'Upload smaller file size';
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

    setState(() {
      if (images.length == 0) {
        //_dashedBoxColor = Colors.red;
        setState(() {
          _isLoading = false;
        });
      }
    });

    return;
  }

  @override
  void initState() {
    super.initState();

    _focus.addListener(_onFocusChange);

    // Start listening to changes.
    //productController.addListener(_setProductName);
  }

  @override
  void dispose() {
    //productController.dispose();

    super.dispose();
  }

  void _onFocusChange() async {
    // Open modal
    if (_focus.hasFocus) {
      // LocationResult? result = await showLocationPicker(
      //     context, Constants.GOOGLE_MAPS_API_KEY,
      //     initialCenter: LatLng(14.5839333, 121.0500025),
      //     countries: ['PH'],
      //     myLocationButtonEnabled: true);

      // // Handle the result in your way
      // if (result != null) {
      //   setState(() {
      //     _latitude = result.latLng!.latitude;
      //     _longitude = result.latLng!.longitude;
      //     _address = result.address;

      //     _locationController.text = _address!;
      //   });

      //   print('latLng:' + result.latLng.toString());
      //   print('address:' + result.address!);
      // }

      _focus.nextFocus();
    }
    debugPrint("Focus: " + _focus.hasFocus.toString());
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      print('loading..');
      return Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.green,
        //strokeWidth: 5,
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
      ));
    }
    print('container..');
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

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
      appBar: AppBar(
        backgroundColor: body_color,
        title: Text(
          'Create Event',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        leading: popArrow(context),
        bottomOpacity: 0.0,
      ),
      backgroundColor: body_color,
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  //keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.words,
                  controller: eventNameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                  // ],
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: 'Event Name',
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
                      return 'Product Name is required!';
                    }
                    return null;
                  },
                ),
              ),
              _showCircularProgress(),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 3,
                  //keyboardType: TextInputType.emailAddress,
                  controller: descriptionController,
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: "Description",
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
                      return 'Description is required!';
                    }
                    return null;
                  },
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
              //   child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         new Flexible(
              //           child: TextFormField(
              //             maxLines: 1,
              //             //keyboardType: TextInputType.emailAddress,
              //             controller: unitController,
              //             autofocus: false,
              //             textInputAction: TextInputAction.next,
              //             decoration: new InputDecoration(
              //               filled: true,
              //               fillColor: Colors.grey[100],
              //               labelText: 'Unit',
              //               hintText: 'kg',
              //               labelStyle: new TextStyle(color: Colors.black),
              //               enabledBorder: OutlineInputBorder(
              //                 borderRadius: BorderRadius.circular(2.0),
              //                 borderSide: BorderSide(
              //                   color: inputBorderColor,
              //                   //width: 2.0,
              //                 ),
              //               ),
              //               focusedBorder: UnderlineInputBorder(
              //                 borderSide: BorderSide(color: Colors.grey[100]),
              //               ),
              //             ),
              //             validator: (value) {
              //               if (value.isEmpty) {
              //                 return 'Unit is required!';
              //               }
              //               return null;
              //             },
              //           ),
              //         ),
              //         new Flexible(
              //           child: TextFormField(
              //             maxLines: 1,
              //             keyboardType: TextInputType.number,
              //             controller: priceController,
              //             autofocus: false,
              //             textInputAction: TextInputAction.next,
              //             decoration: new InputDecoration(
              //               filled: true,
              //               fillColor: Colors.grey[100],
              //               labelText: 'Price',
              //               labelStyle: new TextStyle(color: Colors.black),
              //               enabledBorder: OutlineInputBorder(
              //                 borderRadius: BorderRadius.circular(2.0),
              //                 borderSide: BorderSide(
              //                   color: inputBorderColor,
              //                   //width: 2.0,
              //                 ),
              //               ),
              //               focusedBorder: UnderlineInputBorder(
              //                 borderSide: BorderSide(color: Colors.grey[100]),
              //               ),
              //             ),
              //             validator: (value) {
              //               if (value.isEmpty) {
              //                 return 'Price is required!';
              //               }
              //               return null;
              //             },
              //           ),
              //         ),
              //       ]),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  controller: quotaController,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    //hintText: '1000',
                    labelText: 'Quota',
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
                      return 'Quota is required!';
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
                  keyboardType: TextInputType.number,
                  controller: _locationController,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Mandaluyong City',
                    labelText: 'Location',
                    labelStyle: new TextStyle(color: Colors.black),
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
                  child: SizedBox(
                    height: 40.0,
                    width: double.infinity,
                    child: new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        primary: Colors.green[700],
                      ),
                      child: new Text('Create Event',
                          style: new TextStyle(
                              fontSize: 14.0, color: Colors.white)),
                      onPressed: () {
                        // Post a product
                        createEvent();
                      },
                    ),
                  ))
            ])),
      ),
    );
  }
}
