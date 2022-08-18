import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../models/chat_message.dart';
import '../models/order_item.dart';
import 'package:flutter/material.dart';
import '../util/colors.dart';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

LinearGradient linearGradient() => LinearGradient(
      colors: [Colors.indigo, Colors.blue],
      //stops: [0.0, 0.7],
    );

Widget linearProgress() => LinearProgressIndicator(
    backgroundColor: Colors.green[800],
    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey));

Widget showCircularProgress(bool isLoading) {
  if (isLoading) {
    print('loading..');
    return Center(
        child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      //strokeWidth: 5,
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
    ));
  }
  print('container..');
  return Container(
    height: 0.0,
    width: 0.0,
  );
}

Widget shim(BuildContext context, bool isLoading) {
  return Expanded(
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: isLoading,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: GridView.count(
          childAspectRatio: 0.7, // control the height
          shrinkWrap: true,
          physics:
              new NeverScrollableScrollPhysics(), // NeverScrollableScrollPhysics
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 2,
          // Generate 100 widgets that display their index in the List.
          children: [
            shimmerCard(context),
            shimmerCard(context),
            shimmerCard(context),
            shimmerCard(context),
            shimmerCard(context),
            shimmerCard(context),
          ],
        ),
      ),
    ),
  );
}

Widget shimmerCard(BuildContext context) {
  return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        //height: 200,
        decoration: BoxDecoration(
          //color: Colors.green[900],
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        padding: const EdgeInsets.all(0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
              ),
            ]),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 40),
              child: Container(
                width: double.infinity,
                height: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        )),
      ));
}

void toast({required String message, Color color = Colors.red, int time = 1}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: time,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0);
}

Widget addPhoto(DecorationImage? image) {
  return Container(
    width: 54,
    height: 54,
    alignment: Alignment.topRight,
    margin: EdgeInsets.only(top: 16),
    decoration: BoxDecoration(
        image: image,
        // shape: BoxShape.circle,
        color: Colors.grey[200],
        border: Border.all(color: Colors.white, width: 1)),
    child: Center(
      child: SvgPicture.asset(
        'assets/images/take-image.svg',
        height: 27,
        width: 27,
        color: image != null ? Colors.white : Colors.grey[500],
      ),
    ),
  );
}

void currentFile(String filename) {
  print('=============================' +
      filename +
      '=====================================================================================');
}

// GestureDetector popArrow(context) => GestureDetector(
//       onTap: () => Navigator.pop(context),
//       child: Icon(
//         Icons.keyboard_arrow_left,
//         color: Colors.green[700],
//         size: 30.0,
//       ),
//     );

GestureDetector popArrow(context, {Color? color}) {
  return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.white,
        child: Icon(
          Icons.keyboard_arrow_left,
          color: color != null ? color : Colors.green[700],
          size: 30.0,
        ),
      ));
}

Padding line([double thickness = 1]) => Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: Divider(color: lineColor, thickness: thickness)),
          ]),
    );

AppBar bar(String title) => AppBar(
      title: Text(title),
      backgroundColor: body_color,
      elevation: 0,
      // leading: Icon(
      //   Icons.menu,
      // ),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.settings_applications_sharp,
                color: appBarButtonColor,
                size: 26.0,
              ),
            )),
        // Padding(
        //     padding: EdgeInsets.only(right: 20.0),
        //     child: GestureDetector(
        //       onTap: () {},
        //       child: Icon(Icons.more_vert),
        //     )),
      ],

      bottomOpacity: 0.0,
    );

String upperCase(String text) {
  return text.toUpperCase();
}

String bigButton({required String text, Widget? icon, String? color}) {
  return text.toUpperCase();
}

dynamic getError(Map<String, dynamic>? map, String key) {
  if (map!['errors'][key][0] != null) {
    return map['errors'][key][0];
  }
  return null;
}

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  }
  if (hour < 17) {
    return 'Good Afternoon';
  }
  return 'Good Evening';
}

Widget spin({Color color = Colors.green, double size = 30}) {
  return SpinKitThreeBounce(
    color: color,
    size: size,
  );
}

void deleteStorage() async {
  final SharedPreferences prefs = await _prefs;
  await prefs.remove('userId');
}

double intToDouble(value) {
  if (value is int) {
    int sub = value;
    return sub.toDouble();
  } else {
    return value;
  }
}

Future<List<dynamic>?> fetch(String apiUrl) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(apiUrl);

  var bearerToken = 'Bearer ' + token.toString();
  var result = await http.get(url, headers: <String, String>{
    'Content-Type': 'application/json',
    'Authorization': bearerToken
  });

  Map<String, dynamic> map = json.decode(result.body);

  return map['data'];
}

Future<dynamic> resetPassword(String? email) async {
  final url = Uri.parse(Constants.passwordResetEmail);

  var result = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(<String, String?>{"email": email}));

  if (result.statusCode == 200) {
    print(result.statusCode);
    //print(result.body);
    // var user = User.fromJson(jsonDecode(result.body));
    return json.decode(result.body);
  } else {
    return json.decode(result.body);
  }
}

Future<bool> favorite(String id) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/products/' + id + '/favorites');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.post(url, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': bearerToken
    });

    //Map<String, dynamic> map = json.decode(result.body);
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

Future<dynamic> sendOrder(OrderItem orderItem,
    {required String paymentMethod,
    String? checkoutId,
    int? addressId = 0,
    double shippingFee = 0}) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/orders');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': bearerToken
        },
        body: json.encode(<dynamic, dynamic>{
          "total_amount":
              double.parse(orderItem.product!.price) * orderItem.quantity!,
          "shipping_fee": shippingFee,
          "address_id": addressId,
          "payment_method": paymentMethod,
          "checkout_id": checkoutId,
          "orders_items": [
            {
              "product_id": orderItem.product!.id,
              "quantity": orderItem.quantity.toString(),
              "price": orderItem.product!.price,
              "total":
                  double.parse(orderItem.product!.price) * orderItem.quantity!
            }
          ]
        }));

    Map<String, dynamic>? map = json.decode(result.body);
    print(url.path + '--' + result.statusCode.toString());
    //print(url + result.body);

    if (result.statusCode == 201) {
      return map!['data'];
    }
  } catch (e) {
    print('Error: ' + e.toString());

    return null;
  }

  return null;
}

Future<bool> paymentMethodOrder(String id,
    [String paymentMethod = 'cod']) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(
      Constants.base + '/orders/' + id + '/payment-methods/' + paymentMethod);

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.post(url, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': bearerToken
    });

    //Map<String, dynamic> map = json.decode(result.body);
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

Future<dynamic> sendChatMessage(ChatMessage chatMessage) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url =
      Uri.parse(Constants.base + '/users/' + chatMessage.to! + '/messages');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': bearerToken
        },
        body: json.encode(<dynamic, dynamic>{
          "messages": chatMessage.messages,
          "type": "text"
        }));

    print(url.path + 'message status' + result.statusCode.toString());
    print(url.path + result.body);

    print('chatMessage.message:' + chatMessage.messages!);

    Map<String, dynamic>? map = json.decode(result.body);

    if (result.statusCode == 200) {
      return map!['data'];
    }

    // if (result.statusCode == 200) {
    //   return true;
    // }
  } catch (e) {
    print('Error: ' + e.toString());

    return false;
  }

  return false;
}

Future<List<dynamic>?> fetchUsers() async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/users');

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

Future<List<dynamic>?> fetchMessagesByUser(String userId) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/users/' + userId + '/messages');

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

Future<bool> storePaymayaCustomerId(String? customerId) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/users/paymaya-customers');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': bearerToken
        },
        body: json.encode(<dynamic, dynamic>{
          "customer_id": customerId,
        }));

    print(url.path + 'store customer id' + result.statusCode.toString());
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

Future<bool> storeNewAmount(
    String? transactionId, String checkoutId, String? successAmount) async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/users/paymaya/wallets');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': bearerToken
        },
        body: json.encode(<dynamic, dynamic>{
          "transaction_id": transactionId,
          "checkout_id": checkoutId,
          "success_amount": successAmount,
        }));

    print(url.path + 'store customer id' + result.statusCode.toString());
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
