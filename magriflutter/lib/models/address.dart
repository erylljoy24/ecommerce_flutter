import 'dart:async';
import 'package:magri/services/base_client.dart';

final String columnId = 'id';
final String columnName = 'name';
final String columnPhone = 'phone';
final String columnAddress = 'address';
final String columnstreetAddress = 'street_address';
final String columnBarangay = 'barangay';
final String columnCity = 'city';
final String columnProvince = 'province';
final String columnBarangayId = 'barangay_id';
final String columnCityId = 'city_id';
final String columnProvinceId = 'province_id';
final String columnPostalCode = 'postal_code';
final String columnIsDefault = 'is_default';

class Address {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? barangay;
  String? city;
  String? province;
  String? streetAddress;
  String? completeAddress;
  int? barangayId;
  int? cityId;
  int? provinceId;
  String? postalCode;
  bool? isDefault;

  Address(
      {this.id,
      this.name,
      this.phone,
      this.address,
      this.barangay,
      this.city,
      this.province,
      this.streetAddress,
      this.postalCode,
      this.barangayId,
      this.cityId,
      this.provinceId,
      this.isDefault});

  Address.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    phone = map[columnPhone];
    address = map[columnAddress];
    barangay = map[columnBarangay];
    city = map[columnCity];
    province = map[columnProvince];
    streetAddress = map[columnstreetAddress];
    barangayId = map[columnBarangayId];
    cityId = map[columnCityId];
    provinceId = map[columnProvinceId];
    postalCode = map[columnPostalCode] ?? '0000';
    streetAddress = map[columnstreetAddress];
    isDefault = map[columnIsDefault];
  }
}

Future<dynamic> storeNewAddress(Address address, [int? orderId]) async {
  Map<String, dynamic> payload = {
    "name": address.name,
    "phone_number": address.phone,
    "street_address": address.streetAddress,
    "postal_code": address.postalCode,
    "barangay_id": address.barangayId,
    "city_id": address.cityId,
    "province_id": address.provinceId,
    "order_id": orderId,
  };

  var data = await BaseClient().post('/addresses', payload);

  return data;
}

Future<dynamic> updateAddress(Address address) async {
  Map<String, dynamic> payload = {
    "name": address.name,
    "phone_number": address.phone,
    "street_address": address.streetAddress,
    "postal_code": address.postalCode,
    "barangay_id": address.barangayId,
    "city_id": address.cityId,
    "province_id": address.provinceId,
    "is_default": address.isDefault
  };

  var data =
      await BaseClient().post('/addresses/' + address.id.toString(), payload);

  return data;
}
