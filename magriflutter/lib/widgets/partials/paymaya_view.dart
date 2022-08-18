import 'dart:io';

import 'package:flutter/material.dart';
import 'package:magri/models/order_item.dart';
import 'package:magri/services/paymaya.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayMayaView extends StatefulWidget {
  final String? type;
  final OrderItem? orderItem;
  final double? topUpAmount;
  final String? redirectUrl;
  final String? checkoutId;
  final double? orderAmount;

  PayMayaView(
      {this.type,
      this.orderItem,
      this.topUpAmount,
      this.redirectUrl,
      this.checkoutId,
      this.orderAmount});
  @override
  State<StatefulWidget> createState() => new _PayMayaViewState();
}

class _PayMayaViewState extends State<PayMayaView> {
  Map<String, dynamic>? _checkoutData;

  bool _isLoading = false;
  String? _checkoutId;
  String? _redirectUrl;

  OrderItem? _orderItem;

  String _title = 'Payment';

  Paymaya paymaya = new Paymaya();

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    setOrderItem(widget.orderItem);

    if (widget.type == 'verify') {
      setState(() {
        _title = 'Card Verification';
      });
    }

    setState(() {
      _redirectUrl = widget.redirectUrl;
      _checkoutId = widget.checkoutId;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setOrderItem(OrderItem? orderItem) {
    setState(() {
      _orderItem = orderItem;
    });
  }

  Widget webCheckout() {
    return WebView(
      // 4123450131001381
      initialUrl: _redirectUrl,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest request) {
        print('Redirecting to: ' + request.url);
        // if (request.url.startsWith('https://www.youtube.com/')) {
        //   print('blocking navigation to $request}');
        //   return NavigationDecision.prevent;
        // }
        print('allowing navigation to $request');

        // 4123450131001381
        // If current URL(Redirect URL) is not the same as initial URL
        // then the payment must have result already.
        // We prevent redirect then we check status on the app
        if (request.url.startsWith(PAYMAYA_REDIRECT_BASE)) {
          // paymaya.getStatus(_checkoutId).then((paymentData) {
          //   //Navigator.pop(context);
          //   Navigator.pop(context, {
          //     "result": "success",
          //     "checkoutId": _checkoutId,
          //     "paymentData": paymentData
          //   });
          // });

          Navigator.pop(
              context, {"result": "success", "checkoutId": _checkoutId});
          print('close now');
          return NavigationDecision.prevent;
        }

        return NavigationDecision.navigate;
      },
      // gestureNavigationEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: body_color,
          title: Text(
            _title,
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          leading: popArrow(context),
          bottomOpacity: 0.0,
        ),
        backgroundColor: body_color,
        body: webCheckout());
  }
}
