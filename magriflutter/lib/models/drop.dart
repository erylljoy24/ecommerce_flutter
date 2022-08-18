import 'dart:async';
import 'package:magri/models/dropproduct.dart';
import 'package:magri/models/productcontribution.dart';
import 'package:magri/services/base_client.dart';
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
final String columnDescription = 'description';
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
final String columnParticipantImages = 'participant_images';
final String columnProducts = 'products';
final String columnProductContributions = 'product_contributions';

class Drop {
  String? id;
  String? userName;
  String? imageUrl;
  User? user;
  String? ago;
  String name = '';
  String description =
      'Enter Magri Drop event description here, may it be 1 to 2 sentences to fully explain the event details.';
  String? quota;
  String? totalAmount;
  String? limitAmount;
  String address = '';
  String? percentage;
  double? percentageNumber;
  double? latitude;
  double? longitude;
  String? distance;
  String? dropByName;

  List<User> participants = [];
  List<DropProduct> dropProducts = [];
  List<String> participantImages = [];
  List<ProductContribution> productContributions = [];

  Drop(this.id, this.userName, this.imageUrl, this.ago, this.name, this.quota,
      this.totalAmount, this.address, this.percentage, this.percentageNumber);

  Drop.fromMap(Map<String, dynamic> map) {
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
    dropByName = map['drop_by_name'] ?? 'Juan Dela Cruz';
    if (map[columnParticipants] != null) {
      map[columnParticipants].forEach((participant) {
        participants.add(User.fromMap(participant));
      });
    }

    if (map[columnProducts] != null) {
      map[columnProducts].forEach((product) {
        dropProducts.add(DropProduct.fromMap(product));
      });
    }

    // Default images
    // TODO: remove if needed
    participantImages = [
      "https://images.unsplash.com/photo-1458071103673-6a6e4c4a3413?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
      "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=400&q=80",
      "https://images.unsplash.com/photo-1470406852800-b97e5d92e2aa?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
      // "https://images.unsplash.com/photo-1473700216830-7e08d47f858e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80"
    ];

    if (map[columnParticipantImages] != null) {
      map[columnParticipantImages].forEach((String image) {
        participantImages.add(image);
      });
    }

    if (map[columnProductContributions] != null) {
      map[columnProductContributions].forEach((productContribution) {
        productContributions
            .add(ProductContribution.fromMap(productContribution));
      });
    }

    // TODO: Remove this when API is up
    productContributions.add(ProductContribution(
        id: 1,
        name: "Carrots",
        imageUrl:
            'https://images.unsplash.com/photo-1473700216830-7e08d47f858e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80',
        qty: 1,
        unit: 'kg',
        price: '100',
        total: '100',
        dateTime: '10/12/2021 at 10PM'));
  }

  // From json
  Drop.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        name = json[columnName],
        imageUrl = json[columnImageURL],
        user = User.fromMap(json[columnUser]),
        ago = json[columnAgo],
        quota = json[columnQuota],
        totalAmount = json[columnTotalAmount],
        limitAmount = json[columnLimitAmount],
        address = json[columnAddress],
        percentage = json[columnPercentage],
        percentageNumber = json[columnPercentageNumber].toDouble(),
        latitude = json[columnLatitude] ?? 14.5839333,
        longitude = json[columnLongitude] ?? 121.0500025,
        distance = json[columnDistance] ?? 'km away';
  // json[columnParticipants].forEach((participant) {
  //   participants.add(User.fromMap(participant));
  // });
}

Future<List<Drop>> fetchDrops() async {
  var data = await BaseClient().get('/events');

  // List<Drop> drops = (data as List).map((i) => Drop.fromJson(i)).toList();
  List<Drop> drops = (data as List).map((i) => Drop.fromMap(i)).toList();

  return drops;
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
