import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:magri/models/user.dart';

class ChangeNotifierUser with ChangeNotifier, DiagnosticableTreeMixin {
  User? _user;

  String userImage = '';

  LatLng? _latLng;
  // double _latitude;
  // double _longitude;

  // double get getLatitude => _latitude;
  // double get getLongitude => _longitude;

  LatLng? get getLatLng => _latLng;

  void setLatLang(LatLng latLng) {
    _latLng = latLng;
  }

  // void setLatitude(double latitude) {
  //   _latitude = latitude;
  //   notifyListeners();
  // }

  // void setLongitude(double longitude) {
  //   _longitude = longitude;
  //   notifyListeners();
  // }

  //String get getName => _user.name;

  //String get getUserImage => _user.image;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(item) {
    // Check first if exists in

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void setUser(User? user) {
    if (user != null) {
      _user = user;
      notifyListeners();
      //print('setUser' + user.email);
    }
  }

  String? getUserImage() {
    if (_user == null) {
      return 'https://www.drupal.org/files/user-pictures/picture-2204516-1469808304.png';
    }

    if (_user!.image == null) {
      return 'https://www.drupal.org/files/user-pictures/picture-2204516-1469808304.png';
    }
    //return 'https://www.drupal.org/files/user-pictures/picture-2204516-1469808304.png';
    return _user!.image;
  }

  String? getUserId() {
    if (_user == null) {
      return null;
    }
    return _user!.id;
  }

  String? getUserName() {
    if (_user == null) {
      return 'Beautiful';
    }

    if (_user!.name == null) {
      return 'Beautiful';
    }

    //print("Beautiful" + _user.name.toString());
    if (_user!.name == 'Guest') {
      return 'Beautiful';
    }

    return _user!.name;
  }

  bool getIsGuest() {
    if (_user == null) {
      return true;
    }

    if (_user!.name == 'Guest') {
      return true;
    }
    return false;
  }

  bool? isVerified() {
    if (_user == null) {
      return false;
    }

    return _user!.verified;
  }

  User? getUser() {
    return _user;
  }
}
