import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../Constants.dart' as Constants;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

abstract class BaseAuth {
  // Future<String> signIn(String email, String password);

  // Future<String> signUp(String email, String password);

  // Future<String> signInWithCredential(AuthCredential facebookAuthCred);

  // Future<FirebaseUser> getCurrentUser();

  // Future<void> sendEmailVerification();

  // Future<void> signOut();

  // Future<bool> isEmailVerified();
  Future<String> googleSignIn(GoogleSignInAccount account, String? accessToken);
  Future<String> appleSignIn(String? code);
  Future<String> facebookSignIn(
      Map<String, dynamic> account, String? accessToken);
  Future<String> signIn(String? email, String? password);
  Future<String> signInToken(String? token);
  Future<String> signInGuest(String? appIdKey);
  Future<User> getLoggedInUser();
}

class Auth implements BaseAuth {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Future<String> signIn(String email, String password) async {
  //   AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
  //       email: email, password: password);
  //   FirebaseUser user = result.user;
  //   return user.uid;
  // }

  // Future<String> signUp(String email, String password) async {
  //   AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
  //       email: email, password: password);
  //   FirebaseUser user = result.user;
  //   return user.uid;
  // }

  // Future<String> signInWithCredential(AuthCredential facebookAuthCred) async {
  //   AuthResult result =
  //       await _firebaseAuth.signInWithCredential(facebookAuthCred);
  //   FirebaseUser user = result.user;
  //   return user.uid;
  // }

  // Future<FirebaseUser> getCurrentUser() async {
  //   FirebaseUser user = await _firebaseAuth.currentUser();
  //   return user;
  // }

  // Future<void> signOut() async {
  //   return _firebaseAuth.signOut();
  // }

  // Future<void> sendEmailVerification() async {
  //   FirebaseUser user = await _firebaseAuth.currentUser();
  //   user.sendEmailVerification();
  // }

  // Future<bool> isEmailVerified() async {
  //   FirebaseUser user = await _firebaseAuth.currentUser();
  //   return user.isEmailVerified;
  // }
  late Response baseResult;

  Future<String> googleSignIn(
      GoogleSignInAccount account, String? accessToken) async {
    final url = Uri.parse(Constants.login);
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(<String, String?>{
          "google_token": accessToken,
          "device_name": "iPhone"
        }));

    if (result.statusCode != 200) {
      return 'invalid';
    }

    var id = await writeData(result);

    return id;
  }

  Future<String> appleSignIn(String? appleToken) async {
    final url = Uri.parse(Constants.login);
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(<String, String?>{
          "apple_token": appleToken,
          "device_name": "iPhone"
        }));

    if (result.statusCode != 200) {
      return 'invalid';
    }

    var id = await writeData(result);

    return id;
  }

  Future<String> facebookSignIn(
      Map<String, dynamic> account, String? accessToken) async {
    var user = User.fromFBMap(account);

    print('FB Email:' + user.email!);
    //print('FB Token:' + user.fbToken);
    // await signIn(user.email, 'xxxxx', accessToken);
    final url = Uri.parse(Constants.login);
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(<String, String?>{
          "facebook_token": accessToken,
          "device_name": "iPhone"
        }));

    if (result.statusCode != 200) {
      return 'invalid';
    }

    var id = await writeData(result);

    return id;
  }

  Future<String> signIn(String? email, String? password,
      [String? facebookToken]) async {
    final url = Uri.parse(Constants.login);
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(<String, String?>{
          "email": email,
          "password": password,
          "facebook_token": facebookToken,
          "device_name": "iPhone"
        }));

    if (result.statusCode != 200) {
      return 'invalid';
    }

    var id = await writeData(result);

    return id;
  }

  Future<String> signInToken([String? token]) async {
    final SharedPreferences prefs = await _prefs;
    // final SharedPreferences prefs = await _prefs;

    if (token == null) {
      token = await prefs.getString('token');
    }
    final url = Uri.parse(Constants.base + '/login/token');
    var bearerToken = 'Bearer ' + token!;
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': bearerToken
        },
        body: json.encode(<String, String>{"_token": ''}));
    baseResult = result;

    print(result.statusCode);

    if (result.statusCode != 200) {
      return 'invalid';
    }

    var id = await writeData(result);

    return id;
  }

  Future<String> signInGuest(String? token) async {
    final url = Uri.parse(Constants.loginGuest);

    var result = await http.post(url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(<String, String>{}));

    var id = await writeData(result);

    return id;
  }

  Future<User> getLoggedInUser() async {
    // We can check the shared first
    final SharedPreferences prefs = await _prefs;
    // String? token = await prefs.getString('token');
    String? userId = await prefs.getString('userId');
    String? type = await prefs.getString('type');
    String? name = await prefs.getString('name');
    String? email = await prefs.getString('email');
    String? image = await prefs.getString('image');

    // We can also call API to check for updated wallet amount
    String? userDetails = await prefs.getString('userDetails');

    if (userDetails != null) {
      var details = json.decode(userDetails);
      print(details);

      return new User.fromMap(details['data']);
    }

    return new User(
        id: userId, type: type, name: name, email: email, image: image);
  }

  Future<String> writeData(Response result) async {
    final SharedPreferences prefs = await _prefs;
    print(result.statusCode);
    print(result.body);
    if (result.statusCode == 200) {
      var body = json.decode(result.body);

      // Save the whole details then we can get it something like:
      await prefs.setString('userDetails', result.body);

      await prefs.setString('token', body['token']);
      await prefs.setString('type', body['data']['type']);
      await prefs.setString('userId', body['data']['id'].toString());
      await prefs.setString('name', body['data']['name']);
      await prefs.setString('email', body['data']['email']);
      await prefs.setString('image', body['data']['image']);
      if (body['data']['paymaya_customer_id'] != null) {
        await prefs.setString(
            'paymaya_customer_id', body['data']['paymaya_customer_id']);
      }

      return body['data']['id'].toString();
    }

    return '';
  }

  Future<dynamic> getUserData() async {
    if (baseResult.statusCode == 200) {
      var body = json.decode(baseResult.body);
      return body['data'];
    }
  }
}
