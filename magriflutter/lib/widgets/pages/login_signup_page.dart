import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/models/user.dart';
import 'package:magri/services/authentication.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:magri/widgets/pages/otp.dart';
import 'package:magri/widgets/pages/reset_password.dart';
import 'package:magri/widgets/pages/signup.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth? auth;
  final VoidCallback? loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final UserController userController = Get.put(UserController());

  final _formKey = new GlobalKey<FormState>();

  var loggedIn = false;

  bool _enableSampleAccount = HAS_SAMPLE_ACCOUNT;

  String? _email;
  String? _password;
  String? _errorMessage;

  String? _forgotPasswordEmailMessage;

  // reset password
  String? _resetPasswordemail;

// Initially password is obscure
  bool _obscureText = true;

  late bool _isLoginForm;
  late bool _isLoading;

  late String _loggedEmail;
  String? _profileImage;
  String? _token;
  bool _loggedBefore = false;
  bool? _bioAuthorized = false;

  List<bool>? isSelected;

  bool _keyboardVisible = false;

  final LocalAuthentication auth = LocalAuthentication();
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  GoogleSignInAccount? _currentUser;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Check if user already logged in the pass
  void checkLoggedUser() async {
    final SharedPreferences prefs = await _prefs;
    String? token = await prefs.getString('token');

    String? email = await prefs.getString('email');
    String? image = await prefs.getString('image');

    bool? bioAuthorized = await prefs.getBool('bioAuthorized');
    bool? isGuest = await prefs.getBool('isGuest');

    // If user is guest then set _loggedBefore = false

    print('bioAuthorized' + bioAuthorized.toString());

    setState(() {
      if (email != null) {
        _loggedEmail = email;
        _profileImage = image;
        _token = token;
        //_loggedBefore = true;
        _bioAuthorized = bioAuthorized;
        // If user is guest then set _loggedBefore = false
        if (isGuest == true) {
          _loggedBefore = false;
        }
      }
    });
  }

  Future<void> _checkBiometrics() async {
    bool? canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      print('canCheckBiometrics:' + canCheckBiometrics.toString());
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType>? availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      print('availableBiometrics:' + availableBiometrics.toString());
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    //print(availableBiometrics.length);
    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        // biometricOnly: true,
        localizedReason: 'Scan your fingerprint to authenticate',
        // useErrorDialogs: true,
        // stickyAuth: true
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';

    if (message == 'Authorized') {
      // Then we should store token so than we can use it when user wants to login using
      // face id or finger id
      //loginToken();
    }
    setState(() {
      _authorized = message;
      print('Auth: ' + message);
    });
  }

  void _cancelAuthentication() {
    auth.stopAuthentication();
  }

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    if (validateAndSave()) {
      String? userUid = '';

      try {
        if (_isLoginForm) {
          // Sign in using API

          // Set the email to _loggedEmail
          if (_loggedBefore) {
            //_email = _loggedEmail;
          }

          print(_email);
          print(_password);

          userUid = await widget.auth!.signIn(_email, _password);
          if (userUid == 'invalid') {
            userUid = null;

            setState(() {
              _errorMessage = 'Invalid email or password';
            });
          }

          await widget.auth!.getLoggedInUser().then((user) {
            userController.setUser(user);
          });
          //userUid = await widget.auth.signIn(_email, _password);
          print('Signed in.: $userUid');
        } else {
          // userUid = await widget.auth.signUp(_email, _password);

          // saveUserDetails(userUid);
          // //widget.auth.sendEmailVerification();
          // //_showVerifyEmailSentDialog();
          // print('Signed up user: $userUid');
        }
        setState(() {
          _isLoading = false;
        });

        if (userUid!.length > 0 && userUid != null && _isLoginForm) {
          final SharedPreferences prefs = await _prefs;
          await prefs.setBool('isGuest', false);
          widget.loginCallback!();
        }
      } catch (e) {
        print('Error: $e');
        // setState(() {
        //   _isLoading = false;
        //   _errorMessage = e.message;
        //   _formKey.currentState.reset();
        // });
      }
    }

    setState(() {
      //_errorMessage = '';
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _isLoading = false;
    _isLoginForm = true;
    print('login page');
    super.initState();
    checkLoggedUser();
    _checkBiometrics();
    _getAvailableBiometrics();
  }

  void resetForm() {
    _formKey.currentState!.reset();
    _errorMessage = null;
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  void setLogin() {
    setState(() {
      _loggedBefore = false;
    });
  }

  void loginToken(String? token) async {
    String? userUid = '';
    setState(() {
      _isLoading = true;
    });
    userUid = await widget.auth!.signInToken(token);
    if (userUid == 'invalid') {
      userUid = null;
    }
    setState(() {
      _isLoading = false;
    });

    if (userUid!.length > 0 && userUid != null && _isLoginForm) {
      final SharedPreferences prefs = await _prefs;
      await prefs.setBool('isGuest', false);
      widget.loginCallback!();
    }
  }

  void signInGuest() async {
    String userUid = '';
    setState(() {
      _isLoading = true;
    });
    userUid = await widget.auth!.signInGuest(_token);
    setState(() {
      _isLoading = false;
    });

    if (userUid.length > 0 && userUid != null && _isLoginForm) {
      final SharedPreferences prefs = await _prefs;
      await prefs.setBool('isGuest', true);
      widget.loginCallback!();
    }
  }

  void modalIdontRememberPassword(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: 320,
                padding: EdgeInsets.all(20.0),
                //color: Colors.grey[100],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(children: [
                              Align(
                                child: new GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: new Text(
                                      "Cancel",
                                      style: new TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold),
                                    )),
                                alignment: Alignment.topLeft,
                              ),
                              Align(
                                child: Text("FORGOT PASSWORD"),
                                alignment: Alignment.topCenter,
                              ),
                            ]),
                          ]),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                                child: Divider(color: lineColor, thickness: 1)),
                          ]),
                      Text(
                          "Enter your email address you are using for your account below and we will send you a password reset link."),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0.0, 0.0, 0.0),
                        child: new TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp(r"\s")), // no space
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z0-9.@]')),
                          ],
                          decoration: new InputDecoration(
                            errorText: _forgotPasswordEmailMessage,
                            hintText: 'Email',
                            labelText: 'Email',
                            labelStyle: new TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.0),
                              borderSide: BorderSide(
                                color: inputBorderColor,
                                //width: 2.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green[700]!),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Email can\'t be empty' : null,
                          onSaved: (value) =>
                              _resetPasswordemail = value!.trim(),
                          onChanged: (value) =>
                              _resetPasswordemail = value.trim(),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
                          child: SizedBox(
                              width: double.infinity,
                              height: 40.0,
                              child: _isLoading
                                  ? SpinKitThreeBounce(
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  : new ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        //elevation: 5.0,
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    30.0)),
                                        primary: Colors.green[700],
                                      ),
                                      child: new Text('SEND RESET LINK',
                                          style: new TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.white)),
                                      onPressed: () {
                                        if (_resetPasswordemail == '' ||
                                            _resetPasswordemail == null) {
                                          setModalState(() {
                                            _forgotPasswordEmailMessage =
                                                'Email Cannot be blank.';
                                          });
                                        } else {
                                          bool isValid = RegExp(
                                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(_resetPasswordemail!);

                                          if (isValid == false) {
                                            setModalState(() {
                                              _forgotPasswordEmailMessage =
                                                  'Invalid email address.';
                                            });
                                          } else {
                                            setModalState(() {
                                              _isLoading = true;
                                            });
                                            sendResetPasswordLink(
                                                _resetPasswordemail);
                                          }
                                        }
                                      },
                                    ))),

                      // RaisedButton(
                      //   child: const Text('BACK TO LOG IN'),
                      //   onPressed: () => Navigator.pop(context),
                      // )
                    ],
                  ),
                ),
              ));
        });
      },
    );
  }

  void modalSignUp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 350,
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: new Text(
                              "Cancel",
                              style: new TextStyle(
                                  color: button_beige_text_color,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold),
                            )),
                        flex: 2,
                      ),
                      Expanded(
                        child: Text("FORGOT PASSWORD"),
                        flex: 4,
                      ),
                      Expanded(
                        child: Text(""),
                        flex: 2,
                      ),
                    ],
                  ),
                ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: Divider(color: lineColor, thickness: 1)),
                    ]),
                Text(
                    "Enter your email address you are using for your account below and we will send you a password reset link."),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0.0, 0.0, 0.0),
                  child: new TextFormField(
                    //initialValue: 'fadeshop@example.com',
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    decoration: new InputDecoration(
                      hintText: 'Email',
                      labelText: 'Email',
                      labelStyle: new TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0),
                        borderSide: BorderSide(
                          color: inputBorderColor,
                          //width: 2.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: button_beige_text_color),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Email can\'t be empty' : null,
                    onSaved: (value) => _resetPasswordemail = value!.trim(),
                    onChanged: (value) => _resetPasswordemail = value.trim(),
                    // onChanged: (text) {
                    //   print("First text field: $text");
                    // },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40.0,
                      child: new ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          //elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          //color: Colors.blue,
                          primary: button_color,
                        ),
                        child: new Text('SEND RESET LINK',
                            style: new TextStyle(
                                fontSize: 10.0, color: Colors.white)),
                        onPressed: () =>
                            sendResetPasswordLink(_resetPasswordemail),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget accountAndSignUp() {
    return SafeArea(
        child: Container(
            // color: Colors.red,
            height: 80,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SafeArea(
                          child: Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 16),
                        child: Text("Don't have an account?"),
                      )),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                      ),
                      SafeArea(
                          child: Padding(
                              padding: EdgeInsets.only(right: 16, bottom: 16),
                              child: new GestureDetector(
                                  onTap: () async {
                                    // final result = await Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => Otp()),
                                    // );
                                    _navigateSignUp(context, 'buyer');
                                    // _navigateSignUpCode(context, 'buyer');
                                  },
                                  child: Text('Sign Up',
                                      style: TextStyle(
                                          color: const Color(0XFFFF7648))))))
                    ],
                  ),
                  SafeArea(
                      child: GestureDetector(
                          onTap: () {
                            _navigateSignUp(context, User.SELLER_TYPE);
                          },
                          child: Container(
                            height: 42,
                            width: double.infinity,
                            color: greenColor,
                            child: Center(
                                child: Text(
                                    'WANT TO SELL WITH MAGRI? SELLER SIGN UP HERE',
                                    style: TextStyle(color: Colors.white))),
                          ))),
                ])));
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle.dark); // For battery color

    // Check if keyboard is visible
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    //const iconSize = 50;
    return new Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(20.0), // here the desired height
            child: AppBar(
              backgroundColor: appBarColor,
            )),
        // appBar: new AppBar(
        //   backgroundColor: appBarColor,
        // ),
        backgroundColor: const Color(0XFFFFFFFE),
        bottomNavigationBar: accountAndSignUp(),
        // persistentFooterButtons: [accountAndSignUp()],
        body: LayoutBuilder(
            builder: (context, constraints) => Stack(
                  fit: StackFit.expand, // remove if not needed
                  children: <Widget>[
                    _showForm(context),
                    showCircularProgress(_isLoading),
                  ],
                )));
  }

  _navigateSignUp(BuildContext context, String type) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Signup(type)),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        print('result:' + result['email']);

        setState(() {
          _email = result['email'];
          _password = result['password'];
        });

        print(_email);
        print(_password);

        print('_navigateSignUp' + result['token']);

        loginToken(result['token']);
      }
    }
  }

  _navigateResetPassword(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPassword()),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        print('result:' + result['email']);

        setState(() {
          _email = result['email'];
          _password = result['password'];
        });

        print(_email);
        print(_password);

        print('_navigateSignUp' + result['token']);

        loginToken(result['token']);
      }
    }
  }

//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content:
//              new Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                toggleFormMode();
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  Widget _showForm(context) {
    return new Container(
        // decoration: BoxDecoration(
        //   //color: Colors.red,
        //   image: const DecorationImage(
        //       image: AssetImage('assets/images/bg_login.png'),
        //       alignment: Alignment.bottomRight,
        //       fit: BoxFit.scaleDown,
        //       scale: 0.1),
        // ),
        // padding: EdgeInsets.all(16.0),
        child: new Form(
      key: _formKey,
      child: new ListView(
        shrinkWrap: true,
        children: <Widget>[
          //showSkip(),
          showLogo(),
          showWelcomeBack(),
          // showLoginToContinue(),
          // showProfilePic(),
          showSigninAs(),
          //showBPCText(),
          //showErrorMessage(),
          showEmailInput(),
          showPasswordInput(),
          Align(
              child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: showIdontRememberPassword()),
              alignment: Alignment.bottomRight),
          // showIdontRememberPassword(),
          showPrimaryButton(),
          showOrSignInWith(),
          showOrSignInWithButtons(),
          showHiddenSignUp(),
          //showSecondaryButton(),
          //showThumb(),
          //showNotMe(),
          //showVersion(),
        ],
      ),
    ));
  }

  Widget showErrorMessage() {
    if (_errorMessage!.length > 0 && _errorMessage != null) {
      return Center(
          child: Text(
        _errorMessage!,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      ));
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showSkip() {
    if (_loggedBefore) {
      return Container();
    }
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Padding(
            padding: const EdgeInsets.fromLTRB(40, 15.0, 10, 0.0),
            child: new GestureDetector(
                onTap: () {
                  print('clicked skip for now');
                  signInGuest();
                },
                child: new Text(
                  "SKIP FOR NOW",
                  style: new TextStyle(
                      color: button_beige_text_color,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold),
                ))),
      ]),
    ]);
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(40, 15.0, 10, 0.0),
    //   child: new Text(
    //     "SKIP FOR NOW",
    //     style: new TextStyle(
    //         color: button_beige_text_color,
    //         fontSize: 10.0,
    //         fontWeight: FontWeight.w300),
    //   ),
    // );
  }

  // Widget showSkip() {
  //   return new Padding(padding: const EdgeInsets.fromLTRB(40, 100.0, 40, 0.0),child: ,)
  //   // return new Hero(
  //   //   tag: 'hero',
  //   //   child: Padding(
  //   //     padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0.0),
  //   //     child: Text(
  //   //       "SKIP FOR NOW",
  //   //       style: new TextStyle(
  //   //           color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w300),
  //   //     ),
  //   //   ),
  //   // );
  // }

  // Widget showLogo() {
  //   return new Hero(
  //     tag: 'hero',
  //     child: Padding(
  //       padding: EdgeInsets.fromLTRB(0.0, 49.0, 0.0, 0.0),
  //       child: CircleAvatar(
  //         backgroundColor: Colors.transparent,
  //         radius: 30.0,
  //         child: Image.asset('assets/images/logo-plain.png'),
  //       ),
  //     ),
  //   );
  // }

  Widget showLogo() {
    return new Hero(
      tag: 'show-logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Image.asset(
          'assets/images/logo.png',
          height: 120,
          width: 67,
        ),
      ),
    );
  }

  Widget showWelcomeBack() {
    // if (!_loggedBefore) {
    //   return Container();
    // }
    return new Hero(
        tag: 'welcome',
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20, left: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hello There!',
                    style:
                        TextStyle(fontSize: 24, color: const Color(0XFF3FBC7D)),
                  ),
                  Text(
                    'Sign in to your account',
                    style:
                        TextStyle(fontSize: 16, color: const Color(0XFFB1B1B1)),
                  )
                ]),
          ),
        ));
  }

  Widget showLoginToContinue() {
    if (!_loggedBefore) {
      return Container();
    }
    return new Hero(
      tag: 'show-login',
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text('Login to continue')),
      ),
    );
  }

  Widget showProfilePic() {
    if (!_loggedBefore || _profileImage == null) {
      return Container();
    }

    return new Hero(
        tag: 'show-profile',
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: CircleAvatar(
            //backgroundColor: Colors.white,
            // backgroundImage: NetworkImage(_profileImage),
            backgroundImage: CachedNetworkImageProvider(_profileImage!),

            // child: Image.network(
            //   _profileImage,
            //   height: 70,
            //   width: 70,
            // ),
            radius: 23,
          ),
        ));
  }

  Widget showSigninAs() {
    if (!_loggedBefore) {
      return Container();
    }

    return new Hero(
      tag: 'sign-as',
      child: Padding(
        padding: EdgeInsets.only(top: 20, bottom: 22),
        child: Center(
            child: Text(
          'SIGN IN AS to ' + _loggedEmail.substring(0, 2) + '...',
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: 10,
          ),
        )),
      ),
    );
  }

  Widget showBPCText() {
    if (_loggedBefore) {
      return Container();
    }
    return new Hero(
      tag: 'bpc',
      child: Padding(
        padding: EdgeInsets.fromLTRB(50.0, 26.0, 50.0, 0.0),
        child: Text(
          "Hello there, sign in to continue",
          style: new TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              fontFamily: 'ProximaNova'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    if (_loggedBefore) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(29, 32.0, 29, 0.0),
      child: new TextFormField(
        initialValue: _enableSampleAccount ? 'max.dude@gmail.com' : '',
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        //autofocus: true,
        textInputAction: TextInputAction.next,
        decoration: new InputDecoration(
          errorText: _errorMessage,
          filled: true,
          fillColor: Colors.grey[100],
          hintText: 'Email Address/Phone Number',
          //labelText: 'Email',
          labelStyle: new TextStyle(color: Colors.black),
          // enabledBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.green[700]!),
          // ),
          prefixIcon: new IconButton(
            icon: new Icon(Icons.person_outline),
            color: Colors.green,
            onPressed: () {},
          ),
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
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(2.0),
          //   borderSide: BorderSide(
          //     color: inputBorderColor,
          //     width: 1.0,
          //   ),
          // ),
          // icon: new Icon(
          //   Icons.mail,
          //   color: Colors.grey,
          // )
        ),
        validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value!.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(29, 15.0, 29, 0.0),
      child: new TextFormField(
        initialValue: _enableSampleAccount ? 'aaaaaa' : '',
        maxLines: 1,
        obscureText: _obscureText,
        autofocus: false,
        textInputAction: TextInputAction.go,
        onFieldSubmitted: (term) {
          // process
          validateAndSubmit();
        },
        decoration: new InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          hintText: 'Password',
          //labelText: 'Password',
          labelStyle: new TextStyle(color: Colors.black),
          // enabledBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: button_beige_text_color),
          // ),
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(2.0),
          //   borderSide: BorderSide(
          //     color: inputBorderColor,
          //     //width: 2.0,
          //   ),
          // ),
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
          prefixIcon: new IconButton(
            icon: new Icon(Icons.lock_outline),
            color: Colors.green,
            onPressed: () {},
          ),
          suffixIcon: GestureDetector(
            onLongPress: () {
              setState(() {
                _obscureText = false;
              });
            },
            onLongPressUp: () {
              setState(() {
                _obscureText = true;
              });
            },
            child: new IconButton(
              icon: _obscureText
                  ? new Icon(Icons.visibility_off_outlined)
                  : new Icon(Icons.visibility_outlined),
              color: Colors.grey,
              onPressed: () {
                print('tap');
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          // icon: new Icon(
          //   Icons.lock,
          //   color: Colors.grey,
          // )
        ),
        validator: (value) =>
            value!.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value!.trim(),
      ),
    );
  }

  Widget showIdontRememberPassword() {
    // if (_loggedBefore) {
    //   return Center(
    //       child: Padding(
    //     padding: const EdgeInsets.fromLTRB(40, 15.0, 40, 0.0),
    //     child: new GestureDetector(
    //         onTap: () {
    //           modalIdontRememberPassword(context);
    //         },
    //         child: new Text(
    //           "Forgot Password?",
    //           style: new TextStyle(
    //               color: button_beige_text_color,
    //               fontSize: 10.0,
    //               fontWeight: FontWeight.bold),
    //         )),
    //   ));
    // }

    return Center(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(40, 15.0, 40, 0.0),
      child: new GestureDetector(
          onTap: () {
            // modalIdontRememberPassword(context);
            _navigateResetPassword(context);
            print('tap forgot password');
          },
          child: new Text(
            "Forgot Password?",
            style: new TextStyle(color: Colors.red[400], fontSize: 12.0),
          )),
    ));
  }

  Widget showThumb() {
    // Dont show if not login before or if user dont have any biometric device
    if (!_loggedBefore ||
        !_canCheckBiometrics! ||
        _availableBiometrics!.length == 0 ||
        _bioAuthorized == null ||
        _bioAuthorized == false) {
      return Container();
    }
    return new Hero(
      tag: 'thumb',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 49.0, 0.0, 0.0),
        child: new GestureDetector(
            onTap: () {
              _authenticate();
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/images/ic_fingerprint.png',
                height: 30,
                width: 40,
              ),
              radius: 30,
            )),
      ),
    );
  }

  Widget showNotMe() {
    // Dont show if not login before
    if (!_loggedBefore) {
      return Container();
    }
    return Center(
        child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: new GestureDetector(
            onTap: () {
              setLogin();
            },
            child: new Text(
              "THIS INS'T ME. LOG ME IN.",
              style: new TextStyle(
                  color: button_beige_text_color,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold),
            )
        ),
    ));
  }

  Widget showPrimaryButton() {
    // if (_loggedBefore) {
    //   return Container();
    // }
    return new Padding(
        padding: EdgeInsets.fromLTRB(29.0, 21.0, 29.0, 0.0),
        child: iconActionButton(
            context: context,
            buttonColor: 'green',
            icon: Icon(Icons.login_outlined),
            text: 'sign in',
            enable: !_isLoading,
            callback: validateAndSubmit));
    // return new Padding(
    //     padding: EdgeInsets.fromLTRB(40.0, 45.0, 40.0, 0.0),
    //     child: SizedBox(
    //       height: 40.0,
    //       child: new RaisedButton(
    //         //elevation: 5.0,
    //         shape: new RoundedRectangleBorder(
    //             borderRadius: new BorderRadius.circular(10.0)),
    //         color: Colors.yellow[700],
    //         child: new Text('Sign In',
    //             style: new TextStyle(fontSize: 10.0, color: Colors.black)),
    //         onPressed: validateAndSubmit,
    //       ),
    //     ));
  }

  Widget showOrSignInWith() {
    return Padding(
        padding: EdgeInsets.only(top: 15, bottom: 10),
        child: Center(child: Text('Or sign in with')));
  }

  Widget showOrSignInWithButtons() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () {
                initiateSignIn('G');
              },
              child: Image.asset(
                'assets/images/google.png',
                height: 44,
                width: 44,
                // color: Colors.green,
              )),
          Padding(padding: EdgeInsets.only(right: 30)),
          Platform.isIOS
              ? GestureDetector(
                  onTap: () {
                    initiateSignIn('A');
                  },
                  child: Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Image.asset(
                        'assets/images/apple.png',
                        height: 44,
                        width: 44,
                        // color: Colors.green,
                      )))
              : Container(),
          GestureDetector(
              onTap: () {
                initiateSignIn('FB');
              },
              child: Image.asset(
                'assets/images/facebook.png',
                height: 44,
                width: 44,
                // color: Colors.green,
              )),
        ],
      ),
    );
  }

  Widget showHiddenSignUp() {
    // Show if keyboard is active
    if (_keyboardVisible) {
      return Padding(
          padding: EdgeInsets.only(top: 16), child: accountAndSignUp());
    }

    return Container();
  }

  void initiateSignIn(String type) {
    print(type);
    handleSignIn(type).then((result) {
      print('result::' + result.toString());
      if (result == 1) {
        setState(() {
          loggedIn = true;
          _isLoading = false;
        });
      } else {
        print('no');
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<int> handleSignIn(String type) async {
    setState(() {
      _isLoading = true;
    });
    switch (type) {
      case "FB":
        try {
          // by default the login method has the next permissions ['email','public_profile']
          LoginResult result = await FacebookAuth.instance.login();

          if (result.status == LoginStatus.success) {
            // you are logged
            final AccessToken accessToken = result.accessToken!;
            print(accessToken.toJson());
            print(accessToken.toJson()['token']);
            // get the user data
            final userData = await FacebookAuth.instance.getUserData();

            widget.auth!
                .facebookSignIn(userData, accessToken.toJson()['token'])
                .then((user) {
              setState(() {
                _errorMessage = '';
                loggedIn = true;
                _isLoading = false;
              });
              widget.loginCallback!();
            });

            print(userData);
            return 1;
          }
        } catch (e) {
          // switch (e.errorCode) {
          //   case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
          //     print("You have a previous login operation in progress");
          //     break;
          //   case FacebookAuthErrorCode.CANCELLED:
          //     print("login cancelled");
          //     break;
          //   case FacebookAuthErrorCode.FAILED:
          //     print("login failed");
          //     break;
          // }
          print(e.toString());

          return 0;
        }
        break;
      case "G":
        try {
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            // cancelled login
            print('Google Signin ERROR! googleUser: null!');
            Fluttertoast.showToast(
                msg: 'Google Signin ERROR! googleUser: null!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            return 0;
          }

          GoogleSignInAuthentication googleKey =
              await googleUser.authentication;

          print('accessToken: ' + googleKey.accessToken!);
          // googleUser.authentication.then((googleKey) {
          //   print('accessToken: ' + googleKey.accessToken);
          //   print('idToken: ' + googleKey.idToken);
          //   //print(_googleSignIn.currentUser.displayName);
          // }).catchError((err) {
          //   print('inner error');
          // });
          print('googleUser' + googleUser.toString());
          widget.auth!
              .googleSignIn(googleUser, googleKey.accessToken)
              .then((user) {
            setState(() {
              _errorMessage = '';
              _isLoading = false;
              loggedIn = true;
            });
            widget.loginCallback!();
          });

          return 1;
        } on PlatformException catch (e) {
          print(e.code);
          Fluttertoast.showToast(
              msg: 'PlatformException code:' + e.code,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return 0;
        } catch (e) {
          print('Google Sign-In error');
          print(e);
          Fluttertoast.showToast(
              msg: 'Google Sign-In error!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        break;
      case "A": // Apple
        try {
          final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            webAuthenticationOptions: WebAuthenticationOptions(
              // TODO Set the `clientId` and `redirectUri` arguments to the values you
              // entered in the Apple Developer portal during the setup
              clientId: 'com.hs.magri.services',
              redirectUri: Uri.parse(
                // 'https://magriapp.site/sign_in_with_apple',
                'https://backoffice.magriapp.site/sign_in_with_apple',
              ),
            ),
            // TODO Remove these if you have no need for them
            // nonce: 'example-nonce',
            // state: 'example-state',
          );

          widget.auth!.appleSignIn(credential.identityToken!).then((user) {
            setState(() {
              _errorMessage = '';
              _isLoading = false;
              loggedIn = true;
            });
            widget.loginCallback!();
          });

          // print('working...');
          // print('credential.authorizationCode:' + credential.authorizationCode);
          // print('credential.identityToken:' + credential.identityToken!);
          // print('credential.email:' + credential.email!);
          // print('credential.name:' + credential.givenName!);

          // print(credential);

          // This is the endpoint that will convert an authorization code obtained
          // via Sign in with Apple into a session in your system
          // final signInWithAppleEndpoint = Uri(
          //   scheme: 'https',
          //   host: 'magriapp.site',
          //   path: '/callbacks/sign_in_with_apple',
          //   queryParameters: <String, String>{
          //     // 'code': credential.authorizationCode,
          //     'apple_token': credential.identityToken!,
          //     if (credential.givenName != null)
          //       'firstName': credential.givenName!,
          //     if (credential.familyName != null)
          //       'lastName': credential.familyName!,
          //     'useBundleId':
          //         Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
          //     if (credential.state != null) 'state': credential.state!,
          //   },
          // );

          // final session = await http.Client().post(
          //   signInWithAppleEndpoint,
          // );

          // If we got this far, a session based on the Apple ID credential has been created in your system,
          // and you can now set this as the app's session
          // print(session);

          return 1;
        } catch (error) {
          print('Error: =====> ' + error.toString());
          return 0;
        }
    }
    return 0;
  }

  // Future<FacebookLoginResult> _handleFBSignIn() async {
  //   FacebookLogin facebookLogin = FacebookLogin();
  //   FacebookLoginResult facebookLoginResult =
  //       await facebookLogin.logIn(['email']);
  //   switch (facebookLoginResult.status) {
  //     case FacebookLoginStatus.cancelledByUser:
  //       print("Cancelled");
  //       break;
  //     case FacebookLoginStatus.error:
  //       print("error");
  //       break;
  //     case FacebookLoginStatus.loggedIn:
  //       print("Logged In");
  //       break;
  //   }
  //   return facebookLoginResult;
  // }

  // Future<UserCredential> _handleFBSignIn() async {
  //   // Trigger the sign-in flow
  //   // final LoginResult result = await FacebookAuth.instance.login();

  //   // // Create a credential from the access token
  //   // final FacebookAuthCredential facebookAuthCredential =
  //   //     FacebookAuthProvider.credential(result.accessToken.token);

  //   // // Once signed in, return the UserCredential
  //   // return await FirebaseAuth.instance
  //   //     .signInWithCredential(facebookAuthCredential);
  // }

  // Future<UserCredential> _handleGoogleSignIn() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser.authentication;

  //   // Create a new credential
  //   final GoogleAuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  void saveUserDetails(String userUid) async {}

  void sendResetPasswordLink(String? email) async {
    var result = await resetPassword(email);

    setState(() {
      _isLoading = false;
    });

    print(result);

    print(result['status']);
    print(result['msg']);

    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        title: 'Success',
        desc: 'Code will be sent to email!',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDissmissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback');
          Navigator.pop(context);
        })
      ..show();
  }

  Widget textField(String labelText) {
    return TextFormField(
      //initialValue: 'fadeshop@example.com',
      maxLines: 1,
      //keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
        filled: true,
        fillColor: Colors.white,
        //hintText: hint,
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
          borderSide: BorderSide(color: button_beige_text_color),
        ),
      ),
    );
  }
}
