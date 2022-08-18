import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final String columnId = 'id';
final String columnName = 'name';

class Barangay {
  int? id;
  String? name;

  Barangay({
    this.id,
    this.name,
  });

  Barangay.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
  }

  Barangay.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        name = json[columnName];
}

Future<List<dynamic>?> fetchBarangays(int? cityId) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url =
      Uri.parse(Constants.base + '/cities/' + cityId.toString() + '/barangays');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.get(url, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': bearerToken
    });

    Map<String, dynamic>? map = json.decode(result.body);

    // var myModels =
    //     (map!['data'] as List).map((i) => Barangay.fromJson(i)).toList();

    // print(myModels);

    // var myModels = (json.decode(result.body)['data'] as List)
    //     .map((i) => Barangay.fromJson(i))
    //     .toList();

    // print(myModels);
    print(url.path + result.statusCode.toString());

    if (result.statusCode == 200) {
      return map!['data'];
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

List<Barangay> getBarangays(int cityId) {
  List<Barangay> barangays = [];

  fetchBarangays(cityId).then((dataItems) {
    if (dataItems != null) {
      dataItems.forEach((item) {
        barangays.add(Barangay.fromMap(item));
        print(Barangay.fromMap(item).name);
      });
    }
  });

  return barangays;
}
