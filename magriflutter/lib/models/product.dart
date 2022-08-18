import 'dart:async';
import 'dart:convert';
import 'package:magri/models/product_rating.dart';

import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../util/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String columnId = 'id';
final String columnCategory = 'category';
final String columnCategoryId = 'category_id';
final String columnCategoryNumberItems = 'category_number_items';
final String columnProductName = 'name';
final String columnDescription = 'description';
final String columnUnit = 'unit';
final String columnImageURL = 'image_url';
final String columnThumbImageURL = 'thumb_image_url';
final String columnImages = 'images';
final String columnRatings = 'ratings';
final String columnPrice = 'price';
final String columnStocks = 'stocks';
final String columnSold = 'sold';
final String columnIsFavorite = 'is_favorite';
final String columnLatitude = 'latitude';
final String columnLongitude = 'longitude';
final String columnAddress = 'address';
final String columnDistance = 'distance';
final String columnFeatured = 'featured';
final String columnUser = 'user';
final String columnProductRatings = 'product_ratings';

class Product {
  String? id;
  String? category;
  int? categoryId;
  int? categoryNumberItems;
  String? name;
  String? description;
  String? unit;
  String? imageUrl;
  String? thumbImageUrl;
  String? ratings;
  String price = '';
  String? stocks;
  String? sold;
  late bool isFavorite;
  late double latitude;
  late double longitude;
  String? address;
  late String distance = '';
  late int qty;
  late bool featured;

  List<String> images = [];
  User? user;
  List<ProductRating>? productRatings;

  Product(
      this.id,
      this.category,
      this.name,
      this.description,
      this.imageUrl,
      this.images,
      this.ratings,
      this.price,
      this.stocks,
      this.sold,
      this.qty,
      this.unit,
      this.latitude,
      this.longitude,
      {this.user});

  Product.map(dynamic obj) {
    this.id = obj[columnId];
    this.category = obj[columnCategory];
    this.name = obj[columnProductName];
    this.description = obj[columnDescription];
    this.imageUrl = obj[columnImageURL];
    this.thumbImageUrl = obj[columnThumbImageURL];
    this.ratings = obj[columnRatings];
    this.price = obj[columnPrice];
    this.stocks = obj[columnStocks];
    this.sold = obj[columnSold];
    this.user = obj[columnUser];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      columnCategory: category,
      columnName: name,
      columnImageURL: imageUrl,
      columnThumbImageURL: thumbImageUrl,
      columnRatings: ratings,
      columnPrice: price,
      columnStocks: stocks,
      columnSold: sold,
    };

    return map;
  }

  Product.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    description = map[columnDescription];
    unit = map[columnUnit];
    if (unit!.length > 2) {
      unit = unit!.substring(0, 2); // get only first 2 char
    }

    category = map[columnCategory];
    categoryId = map[columnCategoryId];
    categoryNumberItems = map[columnCategoryNumberItems];
    imageUrl = map[columnImageURL];
    thumbImageUrl = map[columnThumbImageURL];
    map[columnImages].forEach((image) {
      images.add(image.toString());
    });
    // images = map[columnImages];
    ratings = map[columnRatings];
    price = map[columnPrice];
    stocks = map[columnStocks];
    sold = map[columnSold];
    latitude = map[columnLatitude] ?? 14.5839333;
    longitude = map[columnLongitude] ?? 121.0500025;
    address = map[columnAddress] ?? '';
    distance = map[columnDistance] ?? 'km away';
    isFavorite = map[columnIsFavorite] ?? false;
    if (map[columnUser] != null) {
      user = User.fromMap(map[columnUser]);
    }

    featured = map[columnFeatured];

    List<ProductRating> items = [];
    if (map[columnProductRatings] != null) {
      map[columnProductRatings].forEach((item) {
        if (item != null) {
          items.add(ProductRating.fromMap(item));
        }
      });

      productRatings = items;
    }
  }

  // From json
  Product.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        name = json[columnName],
        category = json[columnCategory],
        imageUrl = json[columnImageURL],
        thumbImageUrl = json[columnThumbImageURL],
        ratings = json[columnRatings],
        stocks = json[columnStocks],
        sold = json[columnSold];

  Map<String, dynamic> toJson() => {
        columnId: id,
        columnCategory: category,
        columnName: name,
        columnImageURL: imageUrl,
        columnThumbImageURL: thumbImageUrl,
        columnRatings: ratings,
        columnPrice: price,
        columnStocks: stocks,
        columnSold: sold
      };
}

Future<List<dynamic>?> fetchProducts(
    {int? categoryId,
    String? listType,
    double? latitude,
    double? longitude,
    String? userId,
    double? distance,
    double? priceMin,
    double? priceMax,
    double? ratings,
    String? q}) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  var url = Constants.getProducts + '?x=1';

  if (listType != null) {
    url += '&order=' + listType + '&type=' + listType;
  }

  if (categoryId != null) {
    url += '&category_id=' + categoryId.toString();
  }

  // If have latitude and longitude
  if (latitude != null && longitude != null) {
    url += '&latitude=' +
        latitude.toString() +
        '&longitude=' +
        longitude.toString();
  }

  if (userId != null) {
    url += '&user_id=' + userId;
  }

  if (distance != null) {
    url += '&distance=' + distance.toString();
  }

  if (priceMin != null && priceMax != null) {
    url += '&min=' + priceMin.toString() + '&max=' + priceMax.toString();
  }

  if (ratings != null) {
    url += '&ratings=' + ratings.toString();
  }

  if (listType == 'recentlyviewed') {
    String viewedIds = await getRecentlyViewed();
    url += '&ids=' + viewedIds;
  }

  if (q != '' && q != null) {
    url += '&q=' + q;
  }

  final uri = Uri.parse(url);

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.get(uri, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': bearerToken
    });

    print('_printUri ${uri.toString()}');
    print('_printBearerToken $bearerToken');

    Map<String, dynamic>? map = json.decode(result.body);
    print(url + result.statusCode.toString());

    if (result.statusCode == 200) {
      return map!['data'];
    } else {
      print('offline');
      // Provider.of<ChangeNotifierConnection>(context, listen: false)
      //     .setStatusCode(result.statusCode);
      if (result.statusCode == 401) {
        deleteStorage();
      }

      // if (result.statusCode == 401) {
      //   deleteStorage();
      //   Navigator.of(context).pushNamedAndRemoveUntil(

      //       '/', ModalRoute.withName('/'),
      //       arguments: SignOutArguments(true));
      // }
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<bool> addViewed(Product? product) async {
  final SharedPreferences prefs = await _prefs;

  List<dynamic>? recentlyViewed = [];
  if (prefs.get('recentlyViewed') != null) {
    recentlyViewed = json.decode(prefs.get('recentlyViewed') as String);

    if (recentlyViewed!.contains(product!.id)) {
      print('Exists: recentlyViewed');
    } else {
      print('Dont Exists');
      recentlyViewed.add(product.id);
    }
  } else {
    recentlyViewed.add(product!.id);
  }

  print('recentlyViewed');

  await prefs.setString('recentlyViewed', json.encode(recentlyViewed));

  var viewed = prefs.get('recentlyViewed');
  print(viewed);

  getRecentlyViewed().then((value) {});
  //await prefs.remove('recentlyViewed');
  return true;
}

Future<String> getRecentlyViewed() async {
  final SharedPreferences prefs = await _prefs;

  String? viewedIds = '';

  List<dynamic>? recentlyViewed = [];
  if (prefs.get('recentlyViewed') != null) {
    viewedIds = prefs.get('recentlyViewed') as String?;

    recentlyViewed = json.decode(prefs.get('recentlyViewed') as String);

    viewedIds = recentlyViewed!.join(',');
    print('viewedIds' + viewedIds);
    return viewedIds;
  } else {
    return '';
  }
}
