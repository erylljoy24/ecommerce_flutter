import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:magri/Constants.dart' as Constants;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:magri/models/id_type.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'take_photo.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class VerifyAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  bool _isLoading = false;
  double progress = 0.2;

  CameraDescription? _cameraDescription;

  final idNumberController = new TextEditingController();

  bool _hasImage = false;

  String? _imagePath;

  String _photoErrorMessage = '';

  bool _isCamera = false;

  // Add two variables to the state class to store the CameraController and
  // the Future.
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  List<IdType> _idTypes = [];

  String? _selectedIdType = "1";

  @override
  void initState() {
    super.initState();

    currentFile('verify_account.dart');

    setState(() {
      _idTypes.add(IdType(1, 'Drivers License'));
      _idTypes.add(IdType(2, 'Voters ID'));
      _idTypes.add(IdType(3, 'PRC ID'));
    });

    // if (_cameraDescription != null) {
    //   _controller = CameraController(
    //     // Get a specific camera from the list of available cameras.
    //     _cameraDescription,
    //     // Define the resolution to use.
    //     ResolutionPreset.medium,
    //   );

    //   // Next, initialize the controller. This returns a Future.
    //   _initializeControllerFuture = _controller.initialize();
    // }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  Widget textField(String labelText, [int? line]) {
    return TextFormField(
      maxLines: line,
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

  Widget verifyAccountDefault() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
          key: _formKey,
          child: ListView(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                child: Text('Identification Card')),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                child: Text(
                    '1 Primary ID or 2 Secondary IDs (if applicable) are required for verification')),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
              child: Container(
                  height: 45,
                  decoration: ShapeDecoration(
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 0.1, style: BorderStyle.solid),
                      //borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Select ID Type'),
                      value: _selectedIdType,
                      isDense: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedIdType = newValue;
                          print(newValue);
                        });
                      },
                      items: _idTypes.map((IdType type) {
                        return DropdownMenuItem<String>(
                          value: type.id.toString(),
                          child: Text('   ' + type.name!),
                        );
                      }).toList(),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
              child: TextFormField(
                maxLines: 1,
                autofocus: false,
                controller: idNumberController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'ID Number is required!';
                  }
                  return null;
                },
                decoration: new InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  //hintText: "hint",
                  labelText: 'ID Number',
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
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                child: Text('Upload ID Photo')),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 10.0),
                child: Text(
                    'Pro Tip: Make sure its clear and the whole card is seen in the shot. Dont forget to check its expiry date!')),
            _hasImage
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          //image: NetworkImage(_imagePath),
                          //image: Image.file(File(_imagePath),
                          image: FileImage(File(_imagePath!))),
                    ),
                  )
                : SizedBox(
                    width: 150.0,
                    height: 40.0,
                    child: new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //elevation: 5.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.green)),
                        primary: Colors.white,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.grey,
                              size: 30,
                            ),
                            Text('Tap to take ID Photo',
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.grey))
                          ]),
                      onPressed: () {
                        _navigateTakePhoto(context);
                      },
                    ),
                  ),
            // _photoErrorMessage
            //  'ID Photo is required.',
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                child: _imagePath == null
                    ? Center(
                        child: Text(
                        _photoErrorMessage,
                        style: TextStyle(color: Colors.red),
                      ))
                    : Text('')),
            _hasImage
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                    child: Center(
                        child: GestureDetector(
                      child: Text(
                        'Change Photo ID',
                        style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        setState(() {
                          _hasImage = false;
                          _isCamera = true;
                          _imagePath = null;
                          _navigateTakePhoto(context);
                        });
                      },
                    )))
                : Container(),
            Padding(
                padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
                child: SizedBox(
                  height: 40.0,
                  width: double.infinity,
                  child: _isLoading
                      ? SpinKitThreeBounce(
                          color: Colors.green,
                          size: 20,
                        )
                      : new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3.0,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            primary: Colors.green[700],
                          ),
                          child: Text('Submit',
                              style: new TextStyle(
                                  fontSize: 14.0, color: Colors.white)),
                          onPressed: () async {
                            //Submit form. Check if has ID, Number and image
                            submitVerify(context);
                          },
                        ),
                ))
          ])),
    );
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
          _imagePath = result['imagePath'];
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

  void submitVerify(context) async {
    setState(() {
      _photoErrorMessage = '';
      _isLoading = true;
    });
    if (_imagePath == null) {
      setState(() {
        _isLoading = false;
        _photoErrorMessage = 'ID Photo is required.';
      });
    }

    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await _prefs;
      String? token = await prefs.getString('token');
      var bearerToken = 'Bearer ' + token.toString();

      var image;

      Uint8List? fileByte;

      try {
        String imagePath = _imagePath!;
        _readFileByte(imagePath).then((bytesData) async {
          fileByte = bytesData;
          //do your task here
          image = {
            "filename": 'id_image.jpg',
            "data": base64Encode(fileByte!),
            "type": 'image/jpg'
          };

          final url = Uri.parse(Constants.apiVerify);

          // If the form is valid, display a Snackbar.
          var result = await http.post(url,
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization': bearerToken
              },
              body: json.encode(<dynamic, dynamic>{
                "id_image": image,
                "id_type": _selectedIdType,
                "id_number": idNumberController.text,
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

            AwesomeDialog(
                context: context,
                animType: AnimType.LEFTSLIDE,
                headerAnimationLoop: false,
                dialogType: DialogType.SUCCES,
                title: 'Success',
                desc: 'Details has been sent!',
                btnOkOnPress: () {
                  debugPrint('OnClcik');
                },
                btnOkIcon: Icons.check_circle,
                onDissmissCallback: (type) {
                  debugPrint('Dialog Dismiss from callback');
                  Navigator.pop(context);
                })
              ..show();
          }
        });
      } catch (e) {
        // if path invalid or not able to read
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: body_color,
        title: Text(
          'Verify Account',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        leading: popArrow(context),
        bottomOpacity: 0.0,
      ),
      backgroundColor: body_color,
      body: verifyAccountDefault(),
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
      //         child: Text('Submit',
      //             style: new TextStyle(fontSize: 14.0, color: Colors.white)),
      //         onPressed: () async {
      //           //Submit form. Check if has ID, Number and image
      //           // _selectedIdType
      //           // idNumberController.text
      //           // _imagePath
      //           submitVerify(context);
      //         },
      //       ),
      //     )),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
