import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final String columnId = 'id';
final String columnUserName = 'user_name';
final String columnImageURL = 'image_url';
final String columnUser = 'user';
final String columnAgo = 'ago';
final String columnEventName = 'name';
final String columnQuota = 'quota';
final String columnTotalAmount = 'total_amount';
final String columnLimitAmount = 'limit_amount';
final String columnAddress = 'address';
final String columnPercentage = 'percentage';
final String columnPercentageNumber = 'percentage_number';
final String columnLatitude = 'latitude';
final String columnLongitude = 'longitude';
final String columnDistance = 'distance';

final String columnParticipants = 'participants';

class Event {
  String? id;
  String? userName;
  String? imageUrl;
  User? user;
  String? ago;
  String? name;
  String? quota;
  String? totalAmount;
  String? limitAmount;
  String? address;
  String? percentage;
  double? percentageNumber;
  double? latitude;
  double? longitude;
  String? distance;

  List<User> participants = [];

  Event(this.id, this.userName, this.imageUrl, this.ago, this.name, this.quota,
      this.totalAmount, this.address, this.percentage, this.percentageNumber);

  // Event.map(dynamic obj) {
  //   this.id = obj[columnId];
  //   this.name = obj[columnName];
  //   this.imageUrl = obj[columnImageURL];
  //   this.ratings = obj[columnRatings];
  //   this.price = obj[columnPrice];
  //   this.stocks = obj[columnStocks];
  //   this.sold = obj[columnSold];
  // }

  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     columnId: id,
  //     columnName: name,
  //     columnImageURL: imageUrl,
  //     columnRatings: ratings,
  //     columnPrice: price,
  //     columnStocks: stocks,
  //     columnSold: sold,
  //   };

  //   return map;
  // }

  Event.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    userName = map[columnUserName];
    imageUrl = map[columnImageURL];
    user = User.fromMap(map[columnUser]);
    ago = map[columnAgo];
    name = map[columnEventName];
    quota = map[columnQuota];
    totalAmount = map[columnTotalAmount];
    limitAmount = map[columnLimitAmount];
    address = map[columnAddress];
    percentage = map[columnPercentage];
    double? number = map[columnPercentageNumber].toDouble();
    // percentageNumber = map[columnPercentageNumber] ?? 0.0;
    percentageNumber = number;
    latitude = map[columnLatitude] ?? 14.5839333;
    longitude = map[columnLongitude] ?? 121.0500025;
    distance = map[columnDistance] ?? 'km away';
    map[columnParticipants].forEach((participant) {
      participants.add(User.fromMap(participant));
    });
  }

  // // From json
  // Event.fromJson(Map<String, dynamic> json)
  //     : id = json[columnId],
  //       name = json[columnName],
  //       imageUrl = json[columnImageURL],
  //       ratings = json[columnRatings],
  //       stocks = json[columnStocks],
  //       sold = json[columnSold];

  // Map<String, dynamic> toJson() => {
  //       columnId: id,
  //       columnName: name,
  //       columnImageURL: imageUrl,
  //       columnRatings: ratings,
  //       columnPrice: price,
  //       columnStocks: stocks,
  //       columnSold: sold
  //     };
}

Future<List<dynamic>?> fetchEvents(
    [int? categoryId, double? latitude, double? longitude]) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.getEvents + '?x=1');

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
    } else {
      print('offline');
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

Future<dynamic> findEvent(String? id) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.getEvents + '/' + id.toString());

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
    } else {
      print('offline');
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

Future<dynamic> joinEvent(String id, String participantType, double amount,
    [List<bool>? _selectedCategories]) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  var bearerToken = 'Bearer ' + token.toString();

  final url = Uri.parse(Constants.postEvents + '/' + id + '/join');

  try {
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': bearerToken
        },
        body: json.encode(<dynamic, dynamic>{
          "amount": amount,
          "participant_type": participantType,
          "tags": ""
        }));

    Map<String, dynamic>? map = json.decode(result.body);
    print(url.path + result.statusCode.toString());

    if (result.statusCode == 200) {
      return map!['data'];
    } else {
      print('error');
      return map;
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

Future<List<dynamic>?> fetchEventParticipants(String eventId) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.getEvents + '/' + eventId + '/participants');

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
    } else {
      print('offline');
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}
