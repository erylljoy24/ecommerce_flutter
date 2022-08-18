import 'dart:async';
import 'dart:convert';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final String columnId = 'id';
final String columnName = 'name';

class Province {
  int? id;
  String? name;

  Province({
    this.id,
    this.name,
  });

  Province.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
  }
}

Future<List<dynamic>?> fetchProvinces() async {
  final SharedPreferences prefs = await _prefs;

  //print('pref:' + prefs.get('provinces').toString());
  // If we have data on cache then return the cache data
  if (prefs.get('cache_provinces') != null) {
    List<dynamic>? provinces =
        json.decode(prefs.get('cache_provinces') as String);

    return provinces;
  }

  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/provinces');

  // print('call: ' + url);

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.get(url, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': bearerToken
    });

    Map<String, dynamic>? map = json.decode(result.body);

    print(url.path + result.statusCode.toString());

    if (result.statusCode == 200) {
      await prefs.setString('cache_provinces', json.encode(map!['data']));
      return map['data'];
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

List<Province> getProvinces() {
  List<Province> provinces = [];

  fetchProvinces().then((dataItems) {
    if (dataItems != null) {
      dataItems.forEach((item) {
        provinces.add(Province.fromMap(item));
        //print(Province.fromMap(item).name);
      });
    }
  });

  return provinces;
}
