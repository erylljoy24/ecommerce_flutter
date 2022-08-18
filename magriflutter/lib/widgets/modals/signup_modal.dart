import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/util/colors.dart';
// import 'package:magri/widgets/modals/otp_modal.dart';

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

String? validateFirstName(String value) {
  if (value.length < 3)
    return 'Name must be more than 2 charater';
  else
    return null;
}

Widget firstNameField() {
  return TextFormField(
    //maxLines: line,

    autofocus: false,
    validator: (value) {
      if (value!.isEmpty) {
        return 'This field is required!';
      }
      return null;
    },

    decoration: new InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      //hintText: "hint",
      labelText: 'First Name',
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

final _formKey = GlobalKey<FormState>();

void signupModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SafeArea(
          child: Form(
              key: _formKey,
              child: Stack(children: <Widget>[
                Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 0.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(50, 0.0, 50.0, 0.0),
                              child: Center(
                                child: addPhoto(),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  new Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: textField('First Name'),
                                    ),
                                  ),
                                  new Flexible(
                                    child: textField('Last Name'),
                                  ),
                                ]),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: textField(
                                'Email Address', TextInputType.emailAddress),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
                            child: textField('Password',
                                TextInputType.visiblePassword, true),
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
                            child:
                                textField('Phone Number', TextInputType.number),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(40, 20.0, 40.0, 0.0),
                            child: Text(
                                'By submitting you accept our Terms of Use ad Privacy Policy'),
                          ),
                        ]),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: showSubmitButton(context),
                ),
                closeButton(context),
                title(context),
              ])));
    },
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

Widget title(BuildContext context) {
  return Align(
    alignment: Alignment.topCenter,
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: new GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text('Create Account')),
      ),
    ),
  );
}

Widget addPhoto() {
  return Stack(
    children: [
      Container(
        width: 100,
        height: 100,
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[400],
            border: Border.all(color: Colors.white, width: 1)),
        child: Center(
          child: Icon(
            Icons.photo_camera,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
      Positioned(
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.topRight,
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[700],
          ),
          child: Center(
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        right: 0,
        bottom: 0,
      )
    ],
  );
}

Widget showSubmitButton(context) {
  return new Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: SizedBox(
          height: 40.0,
          width: double.infinity,
          child: new ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 3.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0)),
              primary: Colors.yellow[700],
            ),
            child: new Text('Submit',
                style: new TextStyle(fontSize: 14.0, color: Colors.black)),
            onPressed: () => validateAndSubmit(context),
          )));
}

void validateAndSubmit(context) {
  if (_formKey.currentState!.validate()) {
    // If the form is valid, display a Snackbar.
    // otpModal(context);
  }
}
