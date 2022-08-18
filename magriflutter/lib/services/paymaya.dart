import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import '../models/order_item.dart';

// https://manager-sandbox.paymaya.com/
// https://manager.paymaya.com/

// Come from https://www.base64encode.org/
// Syntax public_key:(colon) leave password blank
// Example w/out quote: "public-key-xxxx:"
// Public pk-tGU4LC1sEuoL7OT90Iiegpc2m4dxSd35JR65YGH0oTu
const PAYMAYA_PUBLIC_KEY =
    'cGstdEdVNExDMXNFdW9MN09UOTBJaWVncGMybTRkeFNkMzVKUjY1WUdIMG9UdTo=';
// Secret sk-H1ZCmtDLsRRQ73aRR8mF6eIrf2l7cHo0EZm8mgWqwnG
const PAYMAYA_SECRET_KEY =
    'c2stSDFaQ210RExzUlJRNzNhUlI4bUY2ZUlyZjJsN2NIbzBFWm04bWdXcXduRzo=';

const PAYMAYA_ENV =
    'https://pg-sandbox.paymaya.com'; //  live https://pg.paymaya.com
const PAYMAYA_REDIRECT_BASE = 'http://shop.someserver.com/';
const PAYMAYA_REDIRECT_SUCCESS = 'http://shop.someserver.com/success';
const PAYMAYA_REDIRECT_FAILURE = 'http://shop.someserver.com/failure';
const PAYMAYA_REDIRECT_CANCEL = 'http://shop.someserver.com/cancel';

const PAYMAYA_REDIRECT_URL = {
  "success": PAYMAYA_REDIRECT_SUCCESS,
  "failure": PAYMAYA_REDIRECT_FAILURE,
  "cancel": PAYMAYA_REDIRECT_CANCEL
};

class Paymaya {
  String? checkoutId;
  String? redirectUrl;
  String? requestReferenceNumber;

  Paymaya({this.checkoutId, this.redirectUrl, this.requestReferenceNumber});

  Future<dynamic> checkout(
      {String type = 'topup', OrderItem? orderItem, double? amount}) async {
    print('======checkout');

    final url = Uri.parse(PAYMAYA_ENV + '/payments/v1/checkouts');

    var token = PAYMAYA_PUBLIC_KEY;

    var item;

    if (type == 'topup') {
      item = {
        "totalAmount": {
          "currency": "PHP",
          "value": amount,
        },
        // 4123450131001381
        "items": [
          {
            "name": "Product Name",
            "quantity": "2",
            "code": "124",
            "description": "Mango",
            "amount": {"value": amount},
            "totalAmount": {"value": amount}
          }
        ],
        'buyer': {
          "firstName": "John",
          "lastName": "Smith",
          "contact": {
            "phone": "9175023198",
            "email": "max@aaa.com",
          },
        },
        "redirectUrl": PAYMAYA_REDIRECT_URL,
        "requestReferenceNumber":
            'MAGRI' + DateTime.now().millisecondsSinceEpoch.toString(),
        "metadata": {}
      };
    }

    try {
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Basic ' + token
          },
          body: json.encode(item));

      Map<String, dynamic>? map = json.decode(result.body);
      print(url.path + '-----' + result.statusCode.toString());

      if (result.statusCode == 200) {
        // setState(() {
        //   _checkoutId = map['checkoutId'];
        //   _redirectUrl = map['redirectUrl'];
        // });
        print(map!['redirectUrl']);
        return map;
      } else {
        print(map.toString());
      }
    } catch (e) {
      print('Error: ' + e.toString());

      return null;
    }

    return null;
  }

  Future<dynamic> prepareCheckout(
      {String type = 'topup',
      OrderItem? orderItem,
      double? topUpAmount}) async {
    print('======prepareCheckout');

    final url = Uri.parse(PAYMAYA_ENV + '/payments/v1/checkouts');

    var token = PAYMAYA_PUBLIC_KEY;

    var item;

    // var item = {
    //   "totalAmount": {
    //     "currency": "PHP",
    //     "value": "1000.00",
    //     // "details": {
    //     //   "discount": "300.00",
    //     //   "serviceCharge": "50.00",
    //     //   "shippingFee": "200.00",
    //     //   "tax": "691.60",
    //     //   "subtotal": "5763.30"
    //     // }
    //   },
    //   // 4123450131001381
    //   "items": [
    //     {
    //       "name": "Tomato",
    //       "code": "CVR-096RE2",
    //       "description": "Big Tomato",
    //       "quantity": "5",
    //       "amount": {"value": "200.00"},
    //       "totalAmount": {"value": "1000.00"}
    //     }
    //   ],
    //   "redirectUrl": {
    //     "success": PAYMAYA_REDIRECT_SUCCESS,
    //     "failure": PAYMAYA_REDIRECT_FAILURE,
    //     "cancel": PAYMAYA_REDIRECT_CANCEL
    //   },
    //   "requestReferenceNumber": "000141386713",
    //   "metadata": {}
    // };

    if (type == 'topup') {
      item = {
        "totalAmount": {
          "currency": "PHP",
          "value": topUpAmount,
        },
        // 4123450131001381
        "items": [
          {
            "name": "Topup",
            "description": "Topup",
            "totalAmount": {"value": topUpAmount}
          }
        ],
        "redirectUrl": PAYMAYA_REDIRECT_URL,
        "requestReferenceNumber": "000141386713",
        "metadata": {}
      };
    }

    try {
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Basic ' + token
          },
          body: json.encode(item));

      Map<String, dynamic>? map = json.decode(result.body);
      print(url.path + '-----' + result.statusCode.toString());

      if (result.statusCode == 200) {
        // setState(() {
        //   _checkoutId = map['checkoutId'];
        //   _redirectUrl = map['redirectUrl'];
        // });
        print(map!['redirectUrl']);
        return map;
        //return map['checkoutId'];
        // checkoutId
        // redirectUrl
      } else {
        print(map.toString());
      }
    } catch (e) {
      print('Error: ' + e.toString());

      return null;
    }

    return null;
  }

  Future<dynamic> getStatus(String checkoutId) async {
    var secretKeyToken = PAYMAYA_SECRET_KEY;
    final url = Uri.parse(PAYMAYA_ENV + '/payments/v1/payments/' + checkoutId);

    try {
      var result = await http.get(url, headers: <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Basic ' + secretKeyToken
      });

      Map<String, dynamic>? map = json.decode(result.body);
      print(url.path + ' Status:' + result.statusCode.toString());

      if (result.statusCode == 200) {
        //print(map.toString());
        return map;
      }
    } catch (e) {
      print('Error: ' + e.toString());
    }

    return null;
  }

  Future<dynamic> createCustomer({dynamic customer}) async {
    print('======createCustomer');

    var url = Uri.parse(PAYMAYA_ENV + '/payments/v1/customers');

    var token = PAYMAYA_SECRET_KEY;

    var customerDetails = {"firstName": "John"};

    if (customer != null) {
      customerDetails = customer;
    }

    try {
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Basic ' + token
          },
          body: json.encode(customerDetails));

      Map<String, dynamic>? map = json.decode(result.body);
      print(url.path + '--' + result.statusCode.toString());

      if (result.statusCode == 200) {
        print(map!['id']);
        print(map['firstName']);
        return map;
      } else {
        print(map.toString());
      }
    } catch (e) {
      print('Error: ' + e.toString());

      return null;
    }

    return null;
  }

  Future<dynamic> createPaymentToken({dynamic card}) async {
    print('======createPaymentToken');
    final url = Uri.parse(PAYMAYA_ENV + '/payments/v1/payment-tokens');

    var token = PAYMAYA_PUBLIC_KEY;

    var cardDetails = {
      "card": {
        "number": "4123450131001381",
        "expMonth": "12",
        "expYear": "2025",
        "cvc": "123"
      }
    };

    if (card != null) {
      cardDetails = {"card": card};
    }

    try {
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Basic ' + token
          },
          body: json.encode(cardDetails));

      Map<String, dynamic>? map = json.decode(result.body);
      print(url.path + '--' + result.statusCode.toString());

      if (result.statusCode == 200) {
        print(map!['paymentTokenId']);
        print(map['state']);
        return map;
      } else {
        print(map.toString());
      }
    } catch (e) {
      print('Error: ' + e.toString());

      return null;
    }

    return null;
  }

  Future<dynamic> createCustomerCards(
      {required String customerId,
      String? paymentTokenId,
      bool isDefault = true}) async {
    print('======createCustomerCards');

    final url = Uri.parse(
        PAYMAYA_ENV + '/payments/v1/customers/' + customerId + '/cards');

    var token = PAYMAYA_SECRET_KEY;

    var details = {
      "paymentTokenId": paymentTokenId,
      'isDefault': isDefault,
      "redirectUrl": PAYMAYA_REDIRECT_URL
    };

    try {
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Basic ' + token
          },
          body: json.encode(details));

      Map<String, dynamic>? map = json.decode(result.body);
      print(url.path + '--' + result.statusCode.toString());

      if (result.statusCode == 200) {
        print(map!['id']);
        print(map['firstName']);
        return map;
      } else {
        print(map.toString());
      }
    } catch (e) {
      print('Error: ' + e.toString());

      return null;
    }

    return null;
  }

  Future<List<dynamic>?> getCustomerCards({required String customerId}) async {
    final url = Uri.parse(
        PAYMAYA_ENV + '/payments/v1/customers/' + customerId + '/cards');

    var token = PAYMAYA_SECRET_KEY;

    try {
      var result = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Basic ' + token
      });

      print(url.path + '--' + result.statusCode.toString());
      List<dynamic>? map = json.decode(result.body);

      print(result.statusCode);

      if (result.statusCode == 200) {
        // print(map['id']);
        // print(map['firstName']);
        return map;
      } else {
        print(map.toString());
      }
    } catch (e) {
      print('Error:: ' + e.toString());

      return null;
    }

    return null;
  }

  // Usually we use this from stored payment methods
  Future<dynamic> createPayment(
      {String? paymentTokenId, double? amount}) async {
    print('======createPayment');

    final url = Uri.parse(PAYMAYA_ENV + '/payments/v1/payments');

    var token = PAYMAYA_SECRET_KEY;

    var details = {
      "paymentTokenId": paymentTokenId,
      "totalAmount": {"amount": amount, "currency": "PHP"},
      "redirectUrl": PAYMAYA_REDIRECT_URL,
    };

    try {
      var result = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Basic ' + token
          },
          body: json.encode(details));

      Map<String, dynamic>? map = json.decode(result.body);
      print(url.path + '--' + result.statusCode.toString());

      if (result.statusCode == 200) {
        print(map!['id']);
        print(map['status']);
        return map;
      } else {
        print(map.toString());
      }
    } catch (e) {
      print('Error: ' + e.toString());

      return null;
    }

    return null;
  }
}
