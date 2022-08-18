import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/pages/my_wallet.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PartialPaymentMethod extends StatefulWidget {
  final User? user;
  final String? paymentMethod;
  PartialPaymentMethod({this.user, this.paymentMethod});
  // PartialPaymentMethod({@required this.user});

  @override
  _PartialPaymentMethodState createState() => _PartialPaymentMethodState();
}

class _PartialPaymentMethodState extends State<PartialPaymentMethod>
    with SingleTickerProviderStateMixin {
  FocusNode _focus = new FocusNode();

  // TextEditingController _nameController = new TextEditingController();
  // TextEditingController _regionController = new TextEditingController();

  Future<void>? _launched;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    // If payment method is wallet then load the wallet widget
  }

  // https://mock-processor-sandbox.paymaya.com/cards
  // https://s3-us-west-2.amazonaws.com/developers.paymaya.com.pg/checkout/checkout.html
  // https://s3-us-west-2.amazonaws.com/developers.paymaya.com.pg/payment-vault/paymentvault.html
  // https://s3-us-west-2.amazonaws.com/developers.paymaya.com.pg/pay-by-paymaya/index.html
  // static const platform = const MethodChannel('paymaya.flutter.dev');

  // String _paymentStatus = 'Pending';

  // Future<void> _payNow() async {
  //   try {
  //     // final int result = await platform.invokeMethod('getBatteryLevel');
  //     final Map params = <String, dynamic>{
  //       'checkout': "pk-eo4sL393CWU5KmveJUaW8V730TTei2zY8zE4dHJDxkF",
  //       'payments': "pk-cP5SfWiULsViVtuswhEKCkuanfXdEkdF6mIRXDnH6A7",
  //       'cardToken': "pk-eo4sL393CWU5KmveJUaW8V730TTei2zY8zE4dHJDxkF",
  //       // Use below for the future for array of items
  //       'items': [
  //         {'name': "Shoes", 'quantity': 1, 'value': 99},
  //         {'name': "Pants", 'quantity': 1, 'value': 199}
  //       ],
  //       "appointment_id": "",
  //       "item_name": "Carrots",
  //       "item_quantity": 101,
  //       "item_value":
  //           200.00, //  May be we can set it as double or string depends on OS
  //       'currency': 'PHP',
  //       'requestReferenceNumber': '1551191039',
  //       // This will create payment token that can be use later
  //       //"createPaymentToken": 'true',
  //     };

  //     // Lets try createPaymentToken
  //     // final String result =
  //     //     await platform.invokeMethod('createPaymentToken', params);

  //     final String result =
  //         await platform.invokeMethod('payViaPayMaya', params);
  //     setState(() {
  //       _paymentStatus = result;
  //     });
  //   } on PlatformException catch (e) {
  //     setState(() {
  //       _paymentStatus = "Failed to get battery level: '${e.message}'.";
  //     });
  //   }

  //   print('Payment Info: ' + _paymentStatus);

  //   setState(() {
  //     _paymentStatus = _paymentStatus;
  //   });
  // }

  // 4123450131001381
  // void payMayaModal(BuildContext context, [String paymentUrl = '']) {
  //   showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(10.0),
  //     ),
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setModalState) {
  //         return Container(
  //             height: 600,
  //             padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
  //             child: WebView(
  //               initialUrl: paymentUrl,
  //               javascriptMode: JavascriptMode.unrestricted,
  //               navigationDelegate: (NavigationRequest request) {
  //                 print('Redirecting to: ' + request.url);
  //                 // if (request.url.startsWith('https://www.youtube.com/')) {
  //                 //   print('blocking navigation to $request}');
  //                 //   return NavigationDecision.prevent;
  //                 // }
  //                 print('allowing navigation to $request');

  //                 // 4123450131001381
  //                 // If current URL(Redirect URL) is not the same as initial URL
  //                 // then the payment must have result already.
  //                 if (request.url.startsWith('http://www.askthemaya.com/')) {
  //                   Navigator.pop(context);
  //                 }

  //                 return NavigationDecision.navigate;
  //               },
  //               // gestureNavigationEnabled: true,
  //             ));
  //       });
  //     },
  //   );
  // }

  // final _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    // const String toLaunch =
    //     'https://payments-web-sandbox.paymaya.com/v2/checkout?id=2c535eb8-329d-4898-bdb4-09cebc8ef2ce';
    return Container(
        height: 100,
        child: widget.paymentMethod == 'wallet'
            ? MyWallet(noBackButton: true, returnTo: 'checkout')
            : Container(
                child: Center(child: Text('Cash on Delivery')),
              ));
  }

  // Widget build1(BuildContext context) {
  //   // const String toLaunch =
  //   //     'https://payments-web-sandbox.paymaya.com/v2/checkout?id=2c535eb8-329d-4898-bdb4-09cebc8ef2ce';
  //   return Container(
  //     height: 100,
  //     child: ListView(
  //       children: [
  //         // ElevatedButton(
  //         //   onPressed: () => setState(() {
  //         //     _launched = _launchInWebViewWithJavaScript(toLaunch);
  //         //   }),
  //         //   child: const Text('Launch in app(JavaScript ON)'),
  //         // ),
  //         Container(
  //             height: 110,
  //             child: widget.paymentMethod == 'wallet'
  //                 ? Wallet(noBackButton: true)
  //                 : Container(
  //                     child: Center(child: Text('Cash on Delivery')),
  //                   ))
  //         // Text('List of cards available here'),
  //         // ElevatedButton(
  //         //   onPressed: () {
  //         //     // _payNow();
  //         //     // 4123450131001381
  //         //     payMayaModal(context,
  //         //         'https://payments-web-sandbox.paymaya.com/v2/checkout?id=b11ea770-0503-4a86-b90f-94444f34fdce');
  //         //   },
  //         //   child: const Text('Add New Card'),
  //         // ),
  //       ],
  //     ),
  //   );
  // }
}
