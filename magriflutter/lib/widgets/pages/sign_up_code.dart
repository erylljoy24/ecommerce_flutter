import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:http/http.dart' as http;
import 'package:magri/Constants.dart' as Constants;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class SignUpCode extends StatefulWidget {
  final VoidCallback? verifyCallback;
  final String? email;
  final bool? hasEmail;

  SignUpCode({this.email, this.hasEmail, this.verifyCallback});
  @override
  State<StatefulWidget> createState() => new _EmailAuthState();
}

class _EmailAuthState extends State<SignUpCode> {
  bool _isLoading = false;
  bool _enableSubmit = false;
  String? _accessToken;

  final _codeController = TextEditingController();

  String? _emailErrorMessage;

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

      print(url.path);

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

        setState(() {
          _accessToken = map['token'];
        });

        widget.verifyCallback!();
        Navigator.pop(context, {
          "token": map['token'],
          "result": "success",
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentFile('sign_up_code.dart');
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context,
          isMain: false,
          title: widget.hasEmail! ? 'Verify Email' : 'Verify Phone'),
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
                        padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
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
                          decoration: new InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelText: widget.hasEmail!
                                ? 'Email verification code'
                                : 'Phone verification code',
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
