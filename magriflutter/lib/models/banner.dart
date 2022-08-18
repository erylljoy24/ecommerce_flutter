final String columnId = 'id';
final String columnName = 'name';
final String columnImageUrl = 'image_url';
final String columnType = 'type';

class BannerModel {
  int? id;
  String? name;
  String? imageUrl;
  String? type;

  BannerModel(this.id, this.name, this.imageUrl, this.type);

  BannerModel.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    imageUrl = map[columnImageUrl];
    type = map[columnType];
  }
}

// Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

// Future<List<dynamic>?> fetchBanners() async {
//   final SharedPreferences prefs = await _prefs;

//   // If we have data on cache then return the cache data
//   // if (prefs.get('cache_banners') != null &&
//   //     prefs.getInt('cache_banners_expired')! >
//   //         DateTime.now().millisecondsSinceEpoch) {
//   //   List<dynamic>? categories =
//   //       json.decode(prefs.get('cache_banners') as String);

//   //   print('from cache');
//   //   return categories;
//   // }

//   String? token = await prefs.getString('token');

//   final url = Uri.parse(Constants.banners);

//   try {
//     var bearerToken = 'Bearer ' + token.toString();
//     var result = await http.get(url, headers: <String, String>{
//       'Accept': 'application/json',
//       'Authorization': bearerToken
//     });

//     Map<String, dynamic>? map = json.decode(result.body);

//     print(url.path + result.statusCode.toString());

//     if (result.statusCode == 200) {
//       await prefs.setString('cache_banners', json.encode(map!['data']));
//       await prefs.setInt('cache_banners_expired',
//           DateTime.now().add(Duration(minutes: 1)).millisecondsSinceEpoch);
//       print('from api');

//       return map['data'];
//     }
//   } catch (e) {
//     print('Error: ' + e.toString());
//   }

//   return null;
// }
