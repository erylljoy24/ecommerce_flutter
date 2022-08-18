import 'package:magri/services/base_client.dart';
import 'package:magri/util/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_item.dart';
import '../models/user.dart';
import 'address.dart';
import 'credit_card.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final String columnId = 'id';
final String columnNumber = 'number';
final String columnSubtotal = 'subtotal';
final String columnTotalAmount = 'total_amount';
final String columnShippingFee = 'shipping_fee';
final String columnStatus = 'status';
final String columnStatusMessage = 'status_message';
final String columnOrderItems = 'orders_items';
final String columnOrderItem = 'order_item';
final String columnUser = 'user'; //  The owner of product
final String columnBuyer = 'buyer';
final String columnShippingAddress = 'shipping_address';
final String columnCreditCard = 'credit_card';
final String columnPaymentMethod = 'payment_method';
final String columnRating = 'rating';
final String columnRatingMessage = 'rating_message';

const STATUS_PENDING = 'pending';
const STATUS_NEW = 'new';
const STATUS_CONFIRMED = 'confirmed';
const STATUS_TODELIVER = 'todeliver';
const STATUS_COMPLETED = 'completed';
const STATUS_CANCELLED = 'cancelled';
const STATUS_REJECTED = 'rejected';

class Order {
  int? id;
  String? number;
  double? totalAmount;
  double? subTotal = 0;
  double? shippingFee = 0.0;
  String? status;
  String statusMessage = '';
  List<OrderItem>? orderItems;
  OrderItem? orderItem;

  User? seller;
  User? buyer;
  Address? shippingAddress;
  CreditCard? creditCard;
  String? paymentMethod;
  double rating = 0.0;
  String ratingMessage = '';

  Order({this.id, this.subTotal, this.totalAmount, this.shippingFee});

  // Order.map(dynamic obj) {
  //   this.id = obj[columnId];
  //   this.category = obj[columnCategory];
  // }

  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     columnId: id,
  //     columnCategory: category,
  //   };

  //   return map;
  // }

  Order.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    number = map[columnNumber];

    subTotal = intToDouble(map[columnSubtotal]);
    totalAmount = intToDouble(map[columnTotalAmount]);
    shippingFee = intToDouble(map[columnShippingFee]);

    status = map[columnStatus];
    statusMessage = map[columnStatusMessage];
    List<OrderItem> items = [];
    if (map[columnOrderItems] != null) {
      map[columnOrderItems].forEach((item) {
        if (item != null) {
          items.add(OrderItem.fromMap(item));
        }
      });

      orderItems = items;
    }

    // orderItem = OrderItem.fromMap(map[columnOrderItem]); // Single Item
    if (map[columnUser] != null) {
      seller = User.fromMap(map[columnUser]);
    }
    if (map[columnBuyer] != null) {
      buyer = User.fromMap(map[columnBuyer]);
    }

    if (map[columnShippingAddress] != null) {
      shippingAddress = Address.fromMap(map[columnShippingAddress]);
    }

    if (map[columnCreditCard] != null) {
      creditCard = CreditCard.fromMap(map[columnCreditCard]);
    }

    paymentMethod = map[columnPaymentMethod];
    rating = intToDouble(map[columnRating]);
    ratingMessage = map[columnRatingMessage];

    // print(map[columnUser]);
  }

  // From json
  Order.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        number = json[columnNumber],
        subTotal = intToDouble(json[columnSubtotal]),
        totalAmount = intToDouble(json[columnTotalAmount]),
        shippingFee = intToDouble(json[columnShippingFee]),
        status = json[columnStatus],
        statusMessage = json[columnStatusMessage],
        // List<OrderItem> items = [];
        // if (map[columnOrderItems] != null) {
        //   map[columnOrderItems].forEach((item) {
        //     if (item != null) {
        //       items.add(OrderItem.fromMap(item));
        //     }
        //   });

        //   orderItems = items;
        // }
        seller =
            json[columnUser] != null ? User.fromMap(json[columnUser]) : null,
        buyer =
            json[columnBuyer] != null ? User.fromMap(json[columnBuyer]) : null,
        shippingAddress = json[columnShippingAddress] != null
            ? Address.fromMap(json[columnShippingAddress])
            : null,
        creditCard = json[columnCreditCard] != null
            ? CreditCard.fromMap(json[columnCreditCard])
            : null,
        paymentMethod = json[columnPaymentMethod],
        rating = intToDouble(json[columnRating]),
        ratingMessage = json[columnRatingMessage];

  // Map<String, dynamic> toJson() => {
  //       columnId: id,
  //       columnCategory: category,
  //       columnSold: sold
  //     };
}

Future<List<Order>> fetchOrders2() async {
  var data = await BaseClient().get('/orders');

  List<Order> orders = (data as List).map((i) => Order.fromJson(i)).toList();

  return orders;
}

Future<List<dynamic>?> fetchOrders() async {
  final SharedPreferences prefs = await _prefs;
  String? token = await prefs.getString('token');

  final url = Uri.parse(Constants.base + '/orders');

  try {
    var bearerToken = 'Bearer ' + token.toString();
    var result = await http.get(url, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': bearerToken
    });

    Map<String, dynamic>? map = json.decode(result.body);
    print('_printResultHere $url $bearerToken');

    if (result.statusCode == 200) {
      return map!['data'];
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }

  return null;
}

Future<bool> orderAction(String id, {String action = 'confirm'}) async {
  String url = '';

  if (action == 'confirm') {
    url = '/orders/' + id + '/confirm';
  }
  if (action == 'deliver') {
    url = '/orders/' + id + '/deliver';
  }

  if (action == 'complete') {
    url = '/orders/' + id + '/complete';
  }

  if (action == 'cancel') {
    url = '/orders/' + id + '/cancel';
  }

  if (action == 'reject') {
    url = '/orders/' + id + '/reject';
  }

  var data = await BaseClient().post(url, {});

  if (data['id'] != null) {
    return true;
  }

  return false;
}

Future<bool> confirmOrder(String id) async {
  bool success = await orderAction(id, action: 'confirm');
  return success;
}

Future<bool> deliverOrder(String id) async {
  bool success = await orderAction(id, action: 'deliver');
  return success;
}

Future<bool> completeOrder(String id) async {
  bool success = await orderAction(id, action: 'complete');
  return success;
}

Future<bool> cancelOrder(String id) async {
  bool success = await orderAction(id, action: 'cancel');
  return success;
}

Future<bool> rejectOrder(String id) async {
  bool success = await orderAction(id, action: 'reject');
  return success;
}

Future<bool> rateOrder(String id, double rating, String ratingMessage) async {
  Map<String, dynamic> payload = {
    "rating": rating,
    "rating_message": ratingMessage
  };
  var data = await BaseClient().post('/orders/' + id + '/rate', payload);

  if (data['id'] != null) {
    return true;
  }

  return false;
}
