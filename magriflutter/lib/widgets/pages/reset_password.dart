import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/email_auth.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:email_validator/email_validator.dart';

class ResetPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _isLoading = false;
  bool _isValidEmail = false;

  final _emailController = TextEditingController();

  String? _emailErrorMessage;

  Widget showSubmitButton(context) {
    return iconActionButton(
        context: context,
        buttonColor: 'green',
        text: 'next',
        enable: _isValidEmail,
        callback: validateAndSubmit);
  }

  void validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _emailErrorMessage = null;
      });

      print(_emailController.text);
      var result = await resetPassword(_emailController.text);

      if (result['error'] != null) {
        setState(() {
          _isLoading = false;
          _emailErrorMessage = result['error'];
        });

        return;
      }

      setState(() {
        _isLoading = false;
      });

      final emailAuthResult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EmailAuth(_emailController.text)),
      );

      print(result);
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
    currentFile('reset_password.dart');
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBarTopWithBack(context, isMain: false, title: 'Reset Password'),
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
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          autofocus: true,
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
                              borderSide: BorderSide(color: Colors.grey[100]!),
                            ),
                          ),
                          onChanged: (value) {
                            final bool isValid = EmailValidator.validate(value);
                            setState(() {
                              _isValidEmail = isValid;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Email is required!';
                            }

                            final bool isValid = EmailValidator.validate(value);
                            // bool isValid = RegExp(
                            //         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            //     .hasMatch(value);

                            if (isValid == false) {
                              return "Invalid email address";
                            }

                            return null;
                          },
                          // validator: (_) => hasValidEmail ? null : _emailErrorMessage,
                        ),
                      ),
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
