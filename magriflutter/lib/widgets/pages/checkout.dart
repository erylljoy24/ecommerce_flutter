import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:magri/models/address.dart';
import 'package:magri/models/changenotifiers/change_notifier_chat_order.dart';
import 'package:magri/models/changenotifiers/change_notifier_payment.dart';
import 'package:magri/models/changenotifiers/changenotifieraddress.dart';
import 'package:magri/models/order.dart';
import 'package:magri/widgets/partials/partial_address.dart';
import 'package:magri/widgets/partials/partial_payment_method.dart';
import 'package:magri/models/order_item.dart';
import 'package:magri/util/helper.dart';
import 'package:provider/provider.dart';

class Checkout extends StatefulWidget {
  final OrderItem? orderItem;
  final String paymentMethod;

  // Checkout({@required this.orderItem});
  Checkout({this.orderItem, this.paymentMethod = 'cod'});

  @override
  State<StatefulWidget> createState() => new _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool _proceedIsLoading = false;
  double progress = 0.2;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void storeAddress(Address address, int? orderId) async {
    var isStored = await storeNewAddress(address, orderId);
    if (isStored) {
      address.province = address.province;
      Navigator.pop(context, {"result": "success", "address": address});
    }

    setState(() {
      _proceedIsLoading = false;
    });
    print(isStored);
  }

  Widget proceedButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
        child: SizedBox(
            height: 40.0,
            width: double.infinity,
            child: new ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                primary: Colors.green[700],
              ),
              child: new Text('Proceed',
                  style: new TextStyle(fontSize: 14.0, color: Colors.white)),
              onPressed: () {
                dynamic address =
                    Provider.of<ChangeNotifierAddress>(context, listen: false)
                        .getAddress;

                // Check if balance is enough
                String? walletAmount =
                    Provider.of<ChangeNotifierPayment>(context, listen: false)
                        .walletAmount;

                print(widget.orderItem!.total);

                if (widget.paymentMethod == 'wallet') {
                  if (double.parse(walletAmount!) <
                      double.parse(widget.orderItem!.total!)) {
                    print('cant process');

                    Fluttertoast.showToast(
                        msg: 'Your wallet amount is not enough!',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    return;
                  }
                }

                print(walletAmount);
                print('total: ' + widget.orderItem!.total!);

                if (address['name'] == '' ||
                    address['phone'] == '' ||
                    address['street_address'] == '' ||
                    address['province_id'] == '' ||
                    address['city_id'] == null ||
                    address['barangay_id'] == null) {
                  print('No');
                  print(address['province_id']);
                  print(address['city_id']);
                  print(address['barangay_id']);

                  Fluttertoast.showToast(
                      msg: 'Please enter required fields!',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  setState(() {
                    _proceedIsLoading = true;
                  });
                  print('proceed');
                  storeAddress(
                      Address(
                        name: address['name'],
                        phone: address['phone'],
                        streetAddress: address['street_address'],
                        provinceId: address['province_id'],
                        cityId: address['city_id'],
                        barangayId: address['barangay_id'],
                        province: address['province_name'],
                        city: address['city_name'],
                        barangay: address['barangay_name'],
                      ),
                      widget.orderItem != null
                          ? widget.orderItem!.orderId
                          : null);
                }

                print(address['name']);
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Checkout',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          leading: popArrow(context),
          bottomOpacity: 0.0,
        ),
        //backgroundColor: Colors.white,
        body: Container(
            color: Colors.grey[100],
            child: ListView(
              children: [
                Padding(padding: EdgeInsets.only(top: 10)),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 20, top: 10),
                          child: Text('Shipping Address')),
                      line(),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: PartialAddress(user: null),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 15)),
                Container(
                  height: 160,
                  padding: EdgeInsets.only(top: 10, bottom: 0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 16, top: 10),
                          child: Text('Payment Method')),
                      line(),
                      PartialPaymentMethod(
                          user: null, paymentMethod: widget.paymentMethod),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 15)),
                widget.orderItem != null
                    ? Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 16, top: 10),
                                child: Text('Item')),
                            line(),
                            Padding(padding: EdgeInsets.only(top: 15)),
                            Container(
                              padding: EdgeInsets.all(15),
                              width: double.infinity,
                              height: 100,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image:
                                                    CachedNetworkImageProvider(
                                                        widget
                                                            .orderItem!
                                                            .product!
                                                            .imageUrl!)),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 200,
                                                  child: Container(
                                                    child: Text(
                                                      widget.orderItem!.product!
                                                          .name!,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'P ' +
                                                      widget.orderItem!.product!
                                                          .price +
                                                      ' x ' +
                                                      widget.orderItem!.quantity
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Total P ' +
                                                      (double.parse(widget
                                                                  .orderItem!
                                                                  .product!
                                                                  .price) *
                                                              widget.orderItem!
                                                                  .quantity!)
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ]),
                            ),
                            Padding(padding: EdgeInsets.only(top: 15)),
                            Padding(padding: EdgeInsets.only(bottom: 10)),
                          ],
                        ),
                      )
                    : Container(),
                Padding(padding: EdgeInsets.only(top: 15)),
              ],
            )),
        bottomNavigationBar: SafeArea(child: proceedButton()));
  }
}
