import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/change_password.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:http/http.dart' as http;
import 'package:magri/Constants.dart' as Constants;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class EmailAuth extends StatefulWidget {
  final String email;
  EmailAuth(this.email);
  @override
  State<StatefulWidget> createState() => new _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  bool _isLoading = false;
  bool _enableSubmit = false;
  bool _resendLoading = false;
  String _sendCode = 'Send Code';
  String? _accessToken;

  final _codeController = TextEditingController();

  String? _emailErrorMessage;

  late Timer _timer;
  int _start = 60;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Widget showSubmitButton(context) {
    return iconActionButton(
        context: context,
        buttonColor: 'green',
        text: 'submit',
        enable: _enableSubmit,
        callback: validateAndSubmit);
  }

  void validateAndSubmit() async {
    setState(() {
      _emailErrorMessage = null;
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final SharedPreferences prefs = await _prefs;
      String? token = await prefs.getString('token');
      var bearerToken = 'Bearer ' + token.toString();

      final url = Uri.parse(Constants.passwordResetCode);

      // If the form is valid, display a Snackbar.
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': bearerToken
          },
          body: json.encode(<dynamic, dynamic>{
            "code": _codeController.text,
            "email": widget.email,
          }));

      if (result.statusCode != 200) {
        print('error');
        print(result.body);
        Map<String, dynamic>? map = json.decode(result.body);
        setState(() {
          if (map!['field'] == 'email') {
            _emailErrorMessage = map['error'];
          }
        });
      } else {
        print(result.statusCode);
        Map<String, dynamic> map = json.decode(result.body);
        // print(result.body);

        setState(() {
          _accessToken = map['token'];
        });

        final emailAuthResult = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangePassword(_accessToken!)),
        );

        // print(map['token']);

        // _accessToken
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    currentFile('email_auth.dart');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void resendCode() async {
    setState(() {
      _resendLoading = true;
      _sendCode = 'Sending...';
    });

    var result = await resetPassword(widget.email);

    setState(() {
      _isLoading = false;
      _start = 60;
      _sendCode = 'Send Code';
    });

    startTimer();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: 'Email Auth'),
      backgroundColor: body_color,
      body: SafeArea(
          child: Form(
              key: _formKey,
              child: Stack(fit: StackFit.expand, children: <Widget>[
                Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(29.0, 0, 29.0, 0.0),
                    child: ListView(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30.0, 0.0, 0.0),
                        child: Text('Verification'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          controller: _codeController,
                          autofocus: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          obscureText: true,
                          // textInputAction: TextInputAction.go,
                          decoration: new InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelText: 'Email verification code',
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
                              borderSide: BorderSide(color: Colors.grey[100]!),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.length == 6) {
                                _enableSubmit = true;
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              } else {
                                _enableSubmit = false;
                              }
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Code is required!';
                            }

                            return null;
                          },
                          // validator: (_) => hasValidEmail ? null : _emailErrorMessage,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      _start <= 0
                          ? GestureDetector(
                              onTap: resendCode, child: Text(_sendCode))
                          : Text("Resend in $_start s"),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                        child: _isLoading ? spin() : showSubmitButton(context),
                      ),
                    ]),
                  ),
                ),
              ]))),
    );
  }
}
