import 'package:flutter/foundation.dart';
import 'package:magri/models/barangay.dart';
import 'package:magri/models/city.dart';

class ChangeNotifierAddress with ChangeNotifier, DiagnosticableTreeMixin {
  List<City> _cities = [];
  List<Barangay> _barangays = [];

  String? _name;
  String? _phoneNumber;
  String? _streetAddress;
  String _postalCode = '';
  int? _selectedProvinceId;
  int? _selectedCityId;
  int? _selectedBarangayId;

  String? _selectedProvinceName;
  String? _selectedCityName;
  String? _selectedBarangayName;

  bool _cityIsLoading = false;

  int? get selectedProvinceId => _selectedProvinceId;
  int? get selectedCityId => _selectedCityId;
  int? get selectedBarangayId => _selectedBarangayId;

  String? get selectedProvinceName => _selectedProvinceName;
  String? get selectedCityName => _selectedCityName;
  String? get selectedBarangayName => _selectedBarangayName;

  bool get cityIsLoading => _cityIsLoading;

  String? get name => _name;
  String? get phoneNumber => _phoneNumber;
  String? get streetAddress => _streetAddress;
  String? get postalCode => _postalCode;

  dynamic get getAddress => {
        "name": _name,
        "phone": _phoneNumber,
        "street_address": _streetAddress,
        "postal_code": _postalCode,
        "province_id": _selectedProvinceId,
        "city_id": _selectedCityId,
        "barangay_id": _selectedBarangayId,
        "province_name": _selectedProvinceName,
        "city_name": _selectedCityName,
        "barangay_name": _selectedBarangayName,
      };

  void setName(String name) {
    _name = name.trim();
    notifyListeners();
  }

  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber.trim();
    notifyListeners();
  }

  void setStreetAddress(String streetAddress) {
    _streetAddress = streetAddress.trim();
    notifyListeners();
  }

  void setPostalCode(String postalCode) {
    _postalCode = postalCode.trim();
    notifyListeners();
  }

  void clearCities() {
    _cities.clear();
    notifyListeners();
  }

  void setCityLoading() {
    _cityIsLoading = true;
    notifyListeners();
  }

  void setCityNotLoading() {
    _cityIsLoading = false;
    notifyListeners();
  }

  void addCity(City city) {
    _cities.add(city);
    notifyListeners();
  }

  List<City> getCities() {
    return _cities;
  }

  void setCities(List<City> cities) {
    _cities = cities;
    notifyListeners();
  }

  void clearBarangays() {
    _barangays.clear();
    notifyListeners();
  }

  void addBarangay(Barangay barangay) {
    _barangays.add(barangay);
    notifyListeners();
  }

  List<Barangay> getBarangays() {
    return _barangays;
  }

  void setProvinceId(int? provinceId) {
    _selectedProvinceId = provinceId;
    print('set setProvinceId');
    notifyListeners();
  }

  void setProvinceName(String? name) {
    _selectedProvinceName = name;
    notifyListeners();
  }

  void setCityName(String? name) {
    _selectedCityName = name;
    notifyListeners();
  }

  void setBarangayName(String? name) {
    _selectedBarangayName = name;
    notifyListeners();
  }

  void setCityId(int? cityId) {
    if (cityId == null) {
      _cityIsLoading = true;
    }
    _selectedCityId = cityId;
    print('set setCityId');

    notifyListeners();
  }

  void setBarangayId(int? barangayId) {
    _selectedBarangayId = barangayId;
    print('set setBarangayId');

    notifyListeners();
  }
}
