import 'dart:async';
import 'package:magri/services/base_client.dart';

final String columnId = 'id';
final String columnName = 'name';
final String columnItems = 'number_items';

class Category {
  int? id;
  String? name;
  String? image;
  int? numberItems;

  Category(this.id, this.name, this.numberItems);

  Category.map(dynamic obj) {
    this.id = obj[columnId];
    this.name = obj[columnName];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      columnName: name,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Category.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    image = map[columnName] + '.png';
    numberItems = map[columnItems];
  }

  Category.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        name = json[columnName],
        image = json[columnName] + '.png',
        numberItems = json[columnItems];
}

Future<List<Category>> fetchCategories() async {
  var data = await BaseClient().get('/categories');

  List<Category> categories =
      (data as List).map((i) => Category.fromJson(i)).toList();

  return categories;
}

// Future<List<dynamic>?> fetchCategories() async {
//   final SharedPreferences prefs = await _prefs;

//   // If we have data on cache then return the cache data
//   if (prefs.get('cache_categories') != null &&
//       prefs.getInt('cache_categories_expired')! >
//           DateTime.now().millisecondsSinceEpoch) {
//     List<dynamic>? categories =
//         json.decode(prefs.get('cache_categories') as String);

//     print('from cache');
//     return categories;
//   }

//   String? token = await prefs.getString('token');

//   final url = Uri.parse(Constants.categories);

//   try {
//     var bearerToken = 'Bearer ' + token.toString();
//     var result = await http.get(url, headers: <String, String>{
//       'Accept': 'application/json',
//       'Authorization': bearerToken
//     });

//     Map<String, dynamic>? map = json.decode(result.body);

//     print(url.path + result.statusCode.toString());

//     if (result.statusCode == 200) {
//       await prefs.setString('cache_categories', json.encode(map!['data']));
//       await prefs.setInt('cache_categories_expired',
//           DateTime.now().add(Duration(minutes: 1)).millisecondsSinceEpoch);
//       print('from api');

//       return map['data'];
//     }
//   } catch (e) {
//     print('Error: ' + e.toString());
//   }

//   return null;
// }
