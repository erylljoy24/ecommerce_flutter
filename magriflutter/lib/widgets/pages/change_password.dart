import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:http/http.dart' as http;
import 'package:magri/Constants.dart' as Constants;
import 'dart:convert';

class ChangePassword extends StatefulWidget {
  final String token;
  ChangePassword(this.token);
  @override
  State<StatefulWidget> createState() => new _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _isLoading = false;
  bool _enableSubmit = false;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

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

      final url = Uri.parse(Constants.passwordUpdate);

      // If the form is valid, display a Snackbar.
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + widget.token
          },
          body: json.encode(<dynamic, dynamic>{
            "password": _passwordController.text,
            "password_confirmation": _confirmController.text,
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

        print(map['token']);

        print('success');

        // Login now
        AwesomeDialog(
            context: context,
            animType: AnimType.LEFTSLIDE,
            headerAnimationLoop: false,
            dialogType: DialogType.SUCCES,
            title: 'Success',
            desc: 'Password has been changed!',
            btnOkOnPress: () {
              debugPrint('OnClcik');
            },
            btnOkIcon: Icons.check_circle,
            onDissmissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback');
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            })
          ..show();
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentFile('change_password.dart');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkPassword() {
    setState(() {
      if ((_passwordController.text == _confirmController.text) &&
          (_passwordController.text != '' && _confirmController.text != '')) {
        _enableSubmit = true;
      } else {
        _enableSubmit = false;
      }
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: 'New Password'),
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
                        child: Text('New Password'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          autofocus: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z0-9.!@#\$&*~]')),
                          ],
                          textInputAction: TextInputAction.next,
                          obscureText: true,
                          decoration: new InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelText: 'Please enter password',
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
                            checkPassword();
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
                        padding: const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                        child: Text('Confirm Password'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _confirmController,
                          autofocus: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z0-9.!@#\$&*~]')),
                          ],
                          textInputAction: TextInputAction.next,
                          obscureText: true,
                          decoration: new InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelText: 'Please confirm password',
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
                            checkPassword();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is required!';
                            }

                            return null;
                          },
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
