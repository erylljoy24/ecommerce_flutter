import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:sms_autofill/sms_autofill.dart';

class Otp extends StatefulWidget {
  final String? phoneNumber;
  Otp({this.phoneNumber});
  @override
  State<StatefulWidget> createState() => new _OtpState();
}

class _OtpState extends State<Otp> {
  bool _isLoading = false;
  double progress = 0.2;

  String _code = '';
  String signature = "{{ app signature }}";

  final firstNameController = TextEditingController();
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

  void validateAndSubmit() async {
    await SmsAutoFill().listenForCode;

    print('listen');
  }

  Widget showSubmitButton(context) {
    return iconActionButton(
        context: context,
        buttonColor: 'yellow',
        text: 'continue',
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

  @override
  void initState() {
    super.initState();

    //createDocument();
    //createUser();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBarTopWithBack(context, isMain: false, title: 'Verify Account'),
      // backgroundColor: body_color,
      backgroundColor: Colors.white,
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
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: Image.asset(
                              'assets/images/otp.png',
                              height: 300,
                              width: 200,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: Center(
                                child: Text(
                              'OTP Verification',
                              style: TextStyle(fontSize: 25),
                            )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0.0, 20.0),
                            child: Center(
                                child:
                                    Text('We have sent your 6-digit OTP to')),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0.0, 20.0),
                            child: Center(
                                child:
                                    Text('+' + widget.phoneNumber.toString())),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0.0, 20.0),
                            child: Center(
                                child: Text('Please enter the code below')),
                          ),
                          PinFieldAutoFill(
                            decoration: UnderlineDecoration(
                              textStyle:
                                  TextStyle(fontSize: 20, color: Colors.black),
                              colorBuilder: FixedColorBuilder(
                                  Colors.black.withOpacity(0.3)),
                            ),
                            currentCode: _code,
                            onCodeSubmitted: (code) {
                              // Submit code
                            },
                            onCodeChanged: (code) {
                              if (code!.length == 6) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(40, 20.0, 40.0, 0.0),
                            child: Row(
                              children: [
                                Text('Didnt received the OTP?'),
                                Text(
                                  ' Resend Code',
                                  style: TextStyle(color: Colors.green[700]),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0.0, 0.0),
                            child: showSubmitButton(context),
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
