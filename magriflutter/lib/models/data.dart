import '../services/authentication.dart';
import 'package:flutter/material.dart';
// class Data {
//   String text;
//   int counter;
//   String dateTime;
//   Data({this.text, this.counter, this.dateTime});
// }

class Data {
  String? text;
  BaseAuth? auth;
  //Future<FirebaseUser> user;
  VoidCallback? logoutCallback;
  Data({this.text, this.auth, this.logoutCallback});
}
