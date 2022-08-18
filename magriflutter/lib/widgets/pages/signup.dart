import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/pages/sign_up_code.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:http/http.dart' as http;
import 'package:magri/Constants.dart' as Constants;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
// import 'package:phone_number/phone_number.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:password_strength/password_strength.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class Signup extends StatefulWidget {
  final String type;
  Signup(this.type);
  @override
  State<StatefulWidget> createState() => new _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isLoading = false;
  bool _submitEnable = true;
  bool _passwordMatch = true;
  bool _weekPassword = false;
  double progress = 0.2;

  String _weakPasswordMessage =
      'Your password should have the following: 1 special symbol, 1 number, 1 uppercase and 1 lowercase letter and a minimum length of 8 characters.';

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _referralCodeController = TextEditingController();

  List<Asset> images = <Asset>[];

  final picker = ImagePicker();

  DecorationImage? _roundImage;

  bool _showCamera = true;

  String? _emailErrorMessage;
  String? _phoneErrorMessage;
  String? _referralErrorMessage;
  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;

  Widget textField(String labelText,
      [TextInputType? textInputType,
      bool? obscureText,
      String Function(String)? validator,
      int? line]) {
    textInputType ??= TextInputType.text;
    obscureText ??= false;

    return TextFormField(
      //maxLines: line,
      keyboardType: textInputType,
      autofocus: false,
      obscureText: obscureText,
      //validator: validator,
      validator: (value) {
        if (value!.isEmpty) {
          return 'This field is required!';
        }
        return null;
      },
      //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: new InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        //hintText: "hint",
        labelText: labelText,
        // helperText: 'Helper text',
        // floatingLabelBehavior: FloatingLabelBehavior.always,
        // errorText: 'err',
        labelStyle: new TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.0),
          borderSide: BorderSide(
            color: inputBorderColor,
            //width: 2.0,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget closeButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: new GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: Colors.green[700],
                child: new Icon(Icons.close),
                radius: 12,
              )),
        ),
      ),
    );
  }

  // Widget title(BuildContext context) {
  //   return Align(
  //     alignment: Alignment.topCenter,
  //     child: SafeArea(
  //       child: Padding(
  //         padding: EdgeInsets.all(40),
  //         child: new GestureDetector(
  //             onTap: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('Create Account')),
  //       ),
  //     ),
  //   );
  // }

  // Widget addPhoto() {
  //   return Container(
  //     width: 54,
  //     height: 54,
  //     alignment: Alignment.topRight,
  //     margin: EdgeInsets.only(top: 16),
  //     decoration: BoxDecoration(
  //         image: _roundImage,
  //         // shape: BoxShape.circle,
  //         color: Colors.grey[200],
  //         border: Border.all(color: Colors.white, width: 1)),
  //     child: Center(
  //       child: SvgPicture.asset(
  //         'assets/images/take-image.svg',
  //         height: 27,
  //         width: 27,
  //         color: Colors.grey[500],
  //       ),
  //     ),
  //   );
  //   return Stack(
  //     children: [
  //       Container(
  //         width: 100,
  //         height: 100,
  //         alignment: Alignment.topRight,
  //         margin: EdgeInsets.only(top: 16),
  //         decoration: BoxDecoration(
  //             image: _roundImage,
  //             shape: BoxShape.circle,
  //             color: Colors.grey[400],
  //             border: Border.all(color: Colors.white, width: 1)),
  //         child: Center(
  //           child: Icon(
  //             Icons.photo_camera,
  //             color: _showCamera ? Colors.white : Colors.transparent,
  //             size: 50,
  //           ),
  //         ),
  //       ),
  //       Positioned(
  //         child: Container(
  //           width: 30,
  //           height: 30,
  //           alignment: Alignment.topRight,
  //           margin: EdgeInsets.only(top: 5),
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: Colors.green[700],
  //           ),
  //           child: Center(
  //             child: Icon(
  //               Icons.edit,
  //               color: Colors.white,
  //               size: 20,
  //             ),
  //           ),
  //         ),
  //         right: 0,
  //         bottom: 0,
  //       )
  //     ],
  //   );
  // }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        selectedAssets: images,
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
      images = resultList;
    });

    if (images.length > 0) {
      Asset asset = images[0];
      asset.getByteData().then((byteData) {
        List<int> imageData = byteData.buffer.asUint8List();

        setState(() {
          print('load');
          _showCamera = false;
          _roundImage = DecorationImage(
              image: MemoryImage(imageData as Uint8List),
              alignment: Alignment.bottomRight,
              fit: BoxFit.fill,
              scale: 0.1);
        });
      });
    }

    return null;
  }

  Widget showSubmitButton(context) {
    return iconActionButton(
        context: context,
        buttonColor: 'green',
        text: 'submit',
        enable: _submitEnable,
        callback: validateAndSubmit);
    // return new Padding(
    //     padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 40.0),
    //     child: SizedBox(
    //       height: 40.0,
    //       width: double.infinity,
    //       child: new RaisedButton(
    //         elevation: 3.0,
    //         shape: new RoundedRectangleBorder(
    //             borderRadius: new BorderRadius.circular(10.0)),
    //         color: Colors.yellow[700],
    //         child: new Text('Submit',
    //             style: new TextStyle(fontSize: 14.0, color: Colors.black)),
    //         // onPressed: () => validateAndSubmit(context),
    //       ),
    //     ));
  }

  void validateForm() async {
    // PhoneNumberUtil plugin = PhoneNumberUtil();
    // RegionInfo region = RegionInfo(name: 'PH', code: 'US', prefix: 63);

    // String springFieldUSASimple = '+63' + phoneController.text;
    // bool isValid = await plugin.validate(springFieldUSASimple, region.code);

    // print(isValid);
  }

  void validatePassword(String type) async {
    double strength = 0;

    setState(() {
      _weekPassword = false;
      _passwordMatch = true;
    });
    if (type == 'password') {
      setState(() {
        _passwordErrorMessage = null;
      });
      strength = estimatePasswordStrength(passwordController.text);

      // if (strength < 0.8) {
      if (strength < 0.68) {
        setState(() {
          _passwordErrorMessage = _weakPasswordMessage;
          _weekPassword = true;
        });
      }

      // print(strength);
    } else if (type == 'confirm') {
      setState(() {
        _confirmPasswordErrorMessage = null;
      });
      strength = estimatePasswordStrength(confirmPasswordController.text);
      // if (strength < 0.8) {
      if (strength < 0.68) {
        setState(() {
          _confirmPasswordErrorMessage = _weakPasswordMessage;
          _weekPassword = true;
        });
      }
    }

    if (passwordController.text != confirmPasswordController.text &&
        passwordController.text != '' &&
        confirmPasswordController.text != '') {
      setState(() {
        _confirmPasswordErrorMessage = 'Password confirmation does not match.';
        _passwordMatch = false;
      });
    }
    print(type);
    print(strength);
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

  //   String springFieldUSASimple = '+63' + phoneController.text;
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

  void validateAndSubmit() async {
    setState(() {
      _emailErrorMessage = null;
      _phoneErrorMessage = null;
      _passwordErrorMessage = null;
    });
    validatePhone();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final SharedPreferences prefs = await _prefs;
      String? token = await prefs.getString('token');
      var bearerToken = 'Bearer ' + token.toString();

      var image;

      if (images.length != 0) {
        ByteData byteData = await images[0].getByteData();
        List<int> imageData = byteData.buffer.asUint8List();

        image = {
          "filename": images[0].name,
          "data": base64Encode(imageData),
          "type": 'image/jpg'
        };
      }

      final url = Uri.parse(Constants.signup);

      // If the form is valid, display a Snackbar.
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': bearerToken
          },
          body: json.encode(<dynamic, dynamic>{
            "type": widget.type,
            "image": image,
            "first_name": firstNameController.text,
            "last_name": lastNameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "phone": _phoneNumberController.text,
            "referral_code_used": _referralCodeController.text,
            "device_name": 'iPhone',
          }));

      if (result.statusCode != 200) {
        print('error');
        print(result.body);
        Map<String, dynamic>? map = json.decode(result.body);
        setState(() {
          if (map!['field'] == 'email') {
            _emailErrorMessage = map['error'];
          }

          if (map['field'] == 'phone') {
            _phoneErrorMessage = map['error'];
          }

          if (map['field'] == 'password') {
            _passwordErrorMessage = map['error'];
          }
        });
      } else {
        print(result.statusCode);
        Map<String, dynamic> map = json.decode(result.body);
        // map['token'];
        print(result.body);

        _navigateSignUpCode(context,
            email: map['data']['email'], hasEmail: emailController.text != '');

        //
        // Navigator.pop(context, {
        //   "token": map['token'],
        //   "result": "success",
        //   "email": emailController.text,
        //   "password": passwordController.text
        // });
      }

      //otpModal(context);
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void verifyCallback() {
    print('verifyCallback');
  }

  _navigateSignUpCode(BuildContext context,
      {String? email, bool? hasEmail}) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SignUpCode(
              // email: emailController.text,
              email: email,
              hasEmail: hasEmail,
              verifyCallback: verifyCallback)),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        Navigator.pop(context, {
          "token": result['token'],
          "result": "success",
          "email": emailController.text,
          "password": passwordController.text
        });
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context,
          isMain: false,
          title: widget.type == User.BUYER_TYPE
              ? 'Create Account'
              : 'Create Seller Account'),
      // appBar: AppBar(
      //   backgroundColor: body_color,
      //   title: Text(
      //     'Create Account',
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   elevation: 0,
      //   leading: popArrow(context),
      //   bottomOpacity: 0.0,
      // ),
      backgroundColor: body_color,
      body: SafeArea(
          child: Form(
              key: _formKey,
              child: Stack(fit: StackFit.expand, children: <Widget>[
                Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(29.0, 0, 29.0, 0.0),
                    child: ListView(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Center(
                          //   child: Padding(
                          //     padding:
                          //         const EdgeInsets.fromLTRB(50, 0.0, 50.0, 0.0),
                          //     child: Center(
                          //       child: new GestureDetector(
                          //           onTap: () {
                          //             // Add image
                          //             print('add image');
                          //             loadAssets();
                          //             //getImage(ImageSource.gallery);
                          //           },
                          //           child: addPhoto()),
                          //     ),
                          //   ),
                          // ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0.0, 0.0, 0.0),
                                child: Center(
                                  child: new GestureDetector(
                                      onTap: () {
                                        // Add image
                                        print('add image');
                                        loadAssets();
                                        //getImage(ImageSource.gallery);
                                      },
                                      child: addPhoto(_roundImage)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                              ),
                              Text(
                                'Take/Upload Profile Photo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: TextFormField(
                              maxLines: 1,
                              textCapitalization: TextCapitalization.words,
                              controller: firstNameController,
                              autofocus: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    '[a-zA-Z. ]')), // with space. check after dot(.)
                                // FilteringTextInputFormatter.allow(RegExp(
                                //     '[a-zA-Z0-9. ]')), // with space. check after dot(.)
                              ],
                              textInputAction: TextInputAction.next,
                              decoration: new InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'First Name',
                                labelStyle: new TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                    //width: 2.0,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[100]!),
                                ),
                              ),
                              onChanged: (value) {
                                validateForm();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'First Name is required!';
                                }
                                return null;
                              },
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: TextFormField(
                              maxLines: 1,
                              textCapitalization: TextCapitalization.words,
                              controller: lastNameController,
                              autofocus: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    '[a-zA-Z. ]')), // with space. check after dot(.)
                                // FilteringTextInputFormatter.allow(RegExp(
                                //     '[a-zA-Z0-9. ]')), // with space. check after dot(.)
                              ],
                              textInputAction: TextInputAction.next,
                              decoration: new InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Last Name',
                                labelStyle: new TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                    //width: 2.0,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[100]!),
                                ),
                              ),
                              onChanged: (value) {
                                validateForm();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Last Name is required!';
                                }
                                return null;
                              },
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              autofocus: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    RegExp(r"\s")), // no space
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z0-9.@]')),
                              ],
                              textInputAction: TextInputAction.next,
                              decoration: new InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Email',
                                labelStyle: new TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                    //width: 2.0,
                                  ),
                                ),
                                errorText: _emailErrorMessage,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[100]!),
                                ),
                              ),
                              onChanged: (value) {
                                validateForm();
                              },
                              validator: (value) {
                                // if (value!.isEmpty) {
                                //   return 'Email is required!';
                                // }

                                // If not empty then validate
                                if (value!.isNotEmpty) {
                                  bool isValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value);

                                  if (isValid == false) {
                                    return "Invalid email address";
                                  }
                                }

                                return null;
                              },
                              // validator: (_) => hasValidEmail ? null : _emailErrorMessage,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.visiblePassword,
                              controller: passwordController,
                              autofocus: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z0-9.!@#\$&*~]')),
                              ],
                              // https://stackoverflow.com/questions/56253787/how-to-handle-textfield-validation-in-password-in-flutter
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              decoration: new InputDecoration(
                                errorText: _passwordErrorMessage,
                                errorMaxLines: 3,
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Password',
                                labelStyle: new TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                    //width: 2.0,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[100]!),
                                ),
                              ),
                              onChanged: (value) {
                                validatePassword('password');
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Password is required!';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.visiblePassword,
                              controller: confirmPasswordController,
                              autofocus: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z0-9.!@#\$&*~]')),
                              ],
                              // https://stackoverflow.com/questions/56253787/how-to-handle-textfield-validation-in-password-in-flutter
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              decoration: new InputDecoration(
                                errorText: _confirmPasswordErrorMessage,
                                errorMaxLines: 3,
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Confirm Password',
                                labelStyle: new TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                    //width: 2.0,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[100]!),
                                ),
                              ),
                              onChanged: (value) {
                                validatePassword('confirm');
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Password is required!';
                                }

                                if (_weekPassword) {
                                  return _weakPasswordMessage;
                                }

                                if (_passwordMatch == false) {
                                  return 'Password confirmation does not match.';
                                }
                                return null;
                              },
                            ),
                          ),
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                          //   child: textField('Confirm Password',
                          //       TextInputType.visiblePassword, true),
                          // ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              controller: _phoneNumberController,
                              autofocus: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              textInputAction: TextInputAction.done,
                              decoration: new InputDecoration(
                                prefix: Text(
                                  '+63 | ',
                                  style: TextStyle(color: Colors.green[800]),
                                ),
                                errorText: _phoneErrorMessage,
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Phone Number',
                                hintText: '9171234567',
                                labelStyle: new TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                    //width: 2.0,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[100]!),
                                ),
                              ),
                              onChanged: (value) {
                                validatePhone();
                              },
                              // validator: validatePhone,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Phone is required!';
                                }
                                if (value.length > 11) {
                                  return 'Invalid Phone Number!';
                                }
                                return _phoneErrorMessage;
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: TextFormField(
                              maxLines: 1,
                              // keyboardType: TextInputType.number,
                              controller: _referralCodeController,
                              autofocus: false,
                              // inputFormatters: [
                              //   FilteringTextInputFormatter.digitsOnly,
                              //   LengthLimitingTextInputFormatter(10),
                              // ],
                              textInputAction: TextInputAction.done,
                              decoration: new InputDecoration(
                                errorText: _referralErrorMessage,
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Referral Code',
                                hintText: '',
                                labelStyle: new TextStyle(color: Colors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                    //width: 2.0,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[100]!),
                                ),
                              ),
                              onChanged: (value) {
                                // validatePhone();
                              },
                              // validator: validatePhone,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(40, 20.0, 40.0, 0.0),
                            child: Text(
                                'By submitting you accept our Terms of Use and Privacy Policy',
                                style: TextStyle(color: Colors.grey[700])),
                          ),

                          _showCircularProgress(),

                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                            child: showSubmitButton(context),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 30.0, 0.0, 0.0),
                            child: Text(
                              'v2.0.0+9',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                  ),
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: showSubmitButton(context),
                // ),
                //closeButton(context),
                //title(context),
              ]))),
      // floatingActionButton: showSubmitButton(context),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
