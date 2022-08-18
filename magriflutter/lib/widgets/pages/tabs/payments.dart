import 'package:flutter/material.dart';
import 'package:magri/models/notif.dart';
import 'package:flutter/services.dart';

class Payments extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  List<Notif> items = [];

  bool isLoading = false;
  double progress = 0.2;

  static const platform = const MethodChannel('paymaya.flutter.dev');

  String? _paymentStatus = 'Pending';

  Future<void> _getBatteryLevel() async {
    String? paymentStatus;
    try {
      // final int result = await platform.invokeMethod('getBatteryLevel');
      final Map params = <String, dynamic>{
        'checkout': "pk-eo4sL393CWU5KmveJUaW8V730TTei2zY8zE4dHJDxkF",
        'payments': "pk-cP5SfWiULsViVtuswhEKCkuanfXdEkdF6mIRXDnH6A7",
        'cardToken': "pk-eo4sL393CWU5KmveJUaW8V730TTei2zY8zE4dHJDxkF",
        // Use below for the future for array of items
        'items': [
          {'name': "Shoes", 'quantity': 1, 'value': 99},
          {'name': "Pants", 'quantity': 1, 'value': 199}
        ],
        "appointment_id": "",
        "appointment_name": "Initial Consultation Fee",
        "appointment_quantity": 1,
        "appointment_value":
            7000.01, //  May be we can set it as double or string depends on OS
        'success': "https://testapp.xxxx.solutions/paymaya/success",
        'failure': "https://testapp.xxxx.solutions/paymaya/success",
        'cancel': "https://testapp.xxxx.solutions/paymaya/success",
        'currency': 'PHP',
        'requestReferenceNumber': '1551191039',
      };
      final String? result =
          await platform.invokeMethod('payViaPayMaya', params);

      paymentStatus = result;
    } on PlatformException catch (e) {
      paymentStatus = "Failed to get battery level: '${e.message}'.";
    }

    print('Payment Info: ' + paymentStatus!);

    setState(() {
      _paymentStatus = paymentStatus;
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        progress = 0.6;
      });
    });

    setState(() {
      //isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text('Payment'),
              onPressed: _getBatteryLevel,
            ),
          ],
        ),
      ),
    );
  }
}
