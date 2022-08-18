import 'package:get/get.dart';
import 'package:magri/models/address.dart';
import 'package:magri/models/barangay.dart';
import 'package:magri/models/city.dart';

class AddressController extends GetxController {
  final _cities = RxList<City>([]);
  final _barangays = RxList<Barangay>([]);
  // List<City> _cities = [];
  // List<Barangay> _barangays = [];
  List<Address> _addresses = [];

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

  List<Address> get addresses => _addresses;

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
    update();
  }

  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber.trim();
    update();
  }

  void setStreetAddress(String streetAddress) {
    _streetAddress = streetAddress.trim();
    update();
  }

  void setPostalCode(String postalCode) {
    _postalCode = postalCode.trim();
    update();
  }

  void addAddress(Address address) {
    _addresses.add(address);
    update();
  }

  void clearCities() {
    _cities.clear();
    update();
  }

  void setCityLoading() {
    _cityIsLoading = true;
    update();
  }

  void setCityNotLoading() {
    _cityIsLoading = false;
    update();
  }

  void addCity(City city) {
    _cities.add(city);
    update();
  }

  List<City> getCities() {
    return _cities;
  }

  void setCities(List<City> cities) {
    _cities.value = cities;
    update();
  }

  void clearBarangays() {
    _barangays.clear();
    update();
  }

  void addBarangay(Barangay barangay) {
    _barangays.add(barangay);
    update();
  }

  List<Barangay> getBarangays() {
    return _barangays;
  }

  void setProvinceId(int? provinceId) {
    _selectedProvinceId = provinceId;
    print('set setProvinceId');
    update();
  }

  void setProvinceName(String? name) {
    _selectedProvinceName = name;
    update();
  }

  void setCityName(String? name) {
    _selectedCityName = name;
    update();
  }

  void setBarangayName(String? name) {
    _selectedBarangayName = name;
    update();
  }

  void setCityId(int? cityId) {
    if (cityId == null) {
      _cityIsLoading = true;
    }
    _selectedCityId = cityId;
    print('set setCityId');

    update();
  }

  void setBarangayId(int? barangayId) {
    _selectedBarangayId = barangayId;
    print('set setBarangayId');

    update();
  }
}
