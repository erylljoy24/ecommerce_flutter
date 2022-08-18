import 'package:magri/models/category.dart';
import 'package:magri/models/user_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final String columnId = 'id';
final String columnType = 'type';
final String columnName = 'name';
final String columnFirstName = 'first_name';
final String columnLastName = 'last_name';
final String columnEmail = 'email';
final String columnTags = 'tags';
final String columnImage = 'image';
final String columnVerified = 'verified';
final String columnToken = 'token';
final String columnItems = 'items';
final String columnLastSeen = 'last_seen';
final String columnReviews = 'reviews';
final String columnRatings = 'ratings';
final String columnRated = 'rated';
final String columnUserRatings = 'user_ratings';
final String columnIsFollowing = 'is_following';
final String columnProducts = 'products';
final String columnCategories = 'categories';
final String columnPaymayaCustomerId = 'paymaya_customer_id';
final String columnWalletAmount = 'wallet_amount';
final String columnMessageTime = 'message_time';
final String columnLastMessage = 'last_message';

class User {
  String? id;
  String? type;
  String? name = '';
  String? firstName = '';
  String? lastName = '';
  String? email;
  late String tags;
  String? image;
  late String items;
  String? reviews;
  late String ratings;
  String? ratingWord;
  bool? rated;
  List<Product>? products = [];
  List<Category>? categories = [];
  bool? isFollowing;
  List<UserRating> userRatings = [];
  String lastSeen = '';
  String? paymayaCustomerId;
  String? walletAmount;
  bool? verified = false;
  String? fbToken;
  String messageTime = '';
  String lastMessage = '';
  String ratingMessage = '';

  static const String SELLER_TYPE = 'seller';
  static const String BUYER_TYPE = 'buyer';

  User(
      {this.id,
      this.type,
      this.name,
      this.firstName,
      this.lastName,
      this.email,
      this.image});

  User.map(dynamic obj) {
    this.id = obj[columnId];
    this.name = obj[columnName];
    this.email = obj[columnEmail];
    this.image = obj[columnImage];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      columnName: name,
      columnEmail: email,
    };

    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    id = map[columnId].toString();
    type = map[columnType]; // user,buyer,both
    name = map[columnName];

    firstName = map[columnFirstName];
    lastName = map[columnLastName];
    if (name == '') {
      name = firstName! + ' ' + lastName!;
    }
    email = map[columnEmail];
    tags = map[columnTags] ?? '';
    image = map[columnImage];
    items = map[columnItems] ?? '';
    lastSeen = map[columnLastSeen] ?? '';
    reviews = map[columnReviews] ?? '';
    ratings = map[columnRatings] ?? '';
    ratingWord = map['rating_word'] ?? '';
    rated = map[columnRated];

    if (map[columnUserRatings] != null) {
      map[columnUserRatings].forEach((userRating) {
        print(userRating);
        userRatings.add(UserRating.fromMap(userRating));
      });
    }
    isFollowing = map[columnIsFollowing] ?? false;
    // products = Product.fromMap(map[columnUser]) ?? null;
    // products = map[columnProducts] ?? null;
    if (map[columnProducts] != null) {
      map[columnProducts].forEach((product) {
        products!.add(Product.fromMap(product));
      });
    }
    if (map[columnCategories] != null) {
      map[columnCategories].forEach((category) {
        categories!.add(Category.fromMap(category));
      });
    }
    paymayaCustomerId = map[columnPaymayaCustomerId] ?? '';
    walletAmount = map[columnWalletAmount] ?? '';
    verified = map[columnVerified];
    messageTime = map[columnMessageTime] ?? '';
    lastMessage = map[columnLastMessage] ?? '';
  }

  // From json
  User.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        name = json[columnName],
        email = json[columnEmail],
        image = json[columnImage];

  Map<String, dynamic> toJson() =>
      {columnId: id, columnName: name, columnEmail: email};

  User.fromFBMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    email = map['email'];
    image = map['picture']['data']['url'] ?? '';
    verified = true;
    fbToken = map['token'];
  }
}

Future<bool> rateSeller(String id, double rating, String ratingMessage) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/users/' + id + '/rate');

  try {
    var bearerToken = 'Bearer ' + token.toString();

    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': bearerToken
        },
        body: json.encode(<String, dynamic>{
          "rating": rating,
          "rating_message": ratingMessage
        }));

    print(url.path + '--' + result.statusCode.toString());
    print(url.path + result.body);

    if (result.statusCode == 200) {
      return true;
    }
  } catch (e) {
    print('Error: ' + e.toString());

    return false;
  }

  return false;
}
