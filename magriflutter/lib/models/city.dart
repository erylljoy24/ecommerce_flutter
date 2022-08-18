import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final String columnId = 'id';
final String columnName = 'name';

class City {
  int? id;
  String? name;

  City({
    this.id,
    this.name,
  });

  City.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
  }

  City.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        name = json[columnName];
}

// Future<List<City>> fetchCities(int? provinceId) async {
//   var data =
//       await BaseClient().get('/provinces/' + provinceId.toString() + '/cities');

//   var cities = (data as List).map((i) => City.fromJson(i)).toList();

//   return cities;
// }

Future<List<dynamic>?> fetchCities(int? provinceId) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(
      Constants.base + '/provinces/' + provinceId.toString() + '/cities');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.get(url, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': bearerToken
    });

    Map<String, dynamic>? map = json.decode(result.body);
    print(url.path + result.statusCode.toString());

    if (result.statusCode == 200) {
      return map!['data'];
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

List<City> getCities(int provinceId) {
  List<City> cities = [];

  fetchCities(provinceId).then((dataItems) {
    if (dataItems != null) {
      dataItems.forEach((item) {
        cities.add(City.fromMap(item));
        //print(City.fromMap(item).name);
      });
    }
  });

  return cities;
}
