import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/models/order.dart';
import 'package:magri/models/user.dart';
import 'package:magri/widgets/modals/rate_order_modal.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/product.dart';

class ViewOrder extends StatefulWidget {
  final Order order;
  final bool isSeller;
  ViewOrder(this.order, {this.isSeller = false});
  @override
  State<StatefulWidget> createState() => new _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder>
    with SingleTickerProviderStateMixin<ViewOrder> {
  final UserController userController = Get.put(UserController());

  bool _isLoading = false;

  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();

    currentFile('view_order.dart');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void rateOrder(BuildContext? context, Order? order) {
    print('rateOrder');
    rateOrderModal(context!, order: order);
  }

  void cancelOrderCallback(BuildContext? context, Order? order) async {
    //TODO show confirm box.
    print('cancel orderCallback');

    showAlertDialog(context!, order!, type: 'cancel');

    // Navigator.pop(context!);
    // rateOrderModal(context!, order!);
  }

  void confirmOrderCallback(BuildContext? context, Order? order) async {
    //TODO show confirm box.
    print('confirmOrderCallback');
    showAlertDialog(context!, order!, type: 'confirm');
    // bool success = await cancelOrder(order!.id.toString());

    // if (success) {
    //   Navigator.pop(context!, {
    //     "result": "success",
    //   });
    // }
  }

  void backCallback(BuildContext? context, Order? order) async {
    print('backCallback');
    Navigator.pop(context!);
  }

  void moveDeliverCallback(BuildContext? context, Order? order) async {
    print('moveDeliverCallback');
    showAlertDialog(context!, order!, type: STATUS_TODELIVER);
  }

  void completeCallback(BuildContext? context, Order? order) async {
    print('completeCallback');
    showAlertDialog(context!, order!, type: STATUS_COMPLETED);
  }

  showAlertDialog(BuildContext context, Order order,
      {String type = 'confirm'}) {
    // can be confirm or cancel
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: SizedBox(
        width: 100,
        height: 30.0,
        child: new RaisedButton(
          //elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.green)),
          color: Colors.green[700],
          child: new Text('Yes',
              style: new TextStyle(fontSize: 12.0, color: Colors.white)),
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            // Confirm order here
            Navigator.pop(context);
            if (type == 'confirm') {
              print('yes to confirm: order id:' + order.id.toString());
              bool success = await confirmOrder(order.id.toString());

              if (success) {
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context, {
                  "result": "success",
                  "status": STATUS_CONFIRMED,
                });
              }
            } else if (type == STATUS_TODELIVER) {
              print('yes to deliver: order id:' + order.id.toString());
              bool success = await deliverOrder(order.id.toString());

              if (success) {
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context, {
                  "result": "success",
                  "status": STATUS_TODELIVER,
                });
              }
              // print('yes to reject: order id:' + orderItem.orderId.toString());
              // reject(orderItem);
            } else if (type == STATUS_COMPLETED) {
              print('yes to deliver: order id:' + order.id.toString());
              bool success = await completeOrder(order.id.toString());

              if (success) {
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context, {
                  "result": "success",
                  "status": STATUS_COMPLETED,
                });
              }
            } else {
              // cancel(orderItem);
              bool success = await cancelOrder(order.id.toString());

              if (success) {
                setState(() {
                  _isLoading = true;
                });
                Navigator.pop(context, {
                  "result": "success",
                  "status": STATUS_CANCELLED,
                });
              }
            }
          },
        ),
      ),
      onPressed: () {
        // Process the order
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: SizedBox(
        width: 100,
        height: 30.0,
        child: new RaisedButton(
          //elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.red)),
          color: Colors.white,
          child: new Text('No',
              style: new TextStyle(fontSize: 12.0, color: Colors.red)),
          onPressed: () {
            print('No to confirm. Do nothing');
            Navigator.pop(context);
          },
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    String title = '';
    String content = '';

    if (type == 'confirm') {
      title = 'Confirm order';
      content = 'Confirm order #' + widget.order.number! + '?';
    }
    if (type == 'cancel') {
      title = 'Cancel order';
      content = 'Cancel order #' + widget.order.number! + '?';
    }
    if (type == STATUS_TODELIVER) {
      title = 'set deliver order';
      content = 'Deliver order #' + widget.order.number! + '?';
    }
    if (type == STATUS_COMPLETED) {
      title = 'Complete order';
      content = 'Complete order #' + widget.order.number! + '?';
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget actionButton(Order order) {
    if (order.status == STATUS_NEW) {
      // If seller then put the option to confirm

      if (widget.isSeller) {
        print('seller');
        return _isLoading
            ? spin()
            : Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    iconActionButton(
                        context: context,
                        buttonColor: 'red',
                        icon: Icon(Icons.close),
                        text: 'cancel',
                        order: order,
                        orderCallback: cancelOrderCallback,
                        isTwoButtons: true,
                        // isLoading: _isLoading,
                        callback: null),
                    iconActionButton(
                        context: context,
                        buttonColor: 'green',
                        // icon: Icon(Icons.close),
                        text: 'confirm',
                        order: order,
                        orderCallback: confirmOrderCallback,
                        isTwoButtons: true,
                        // isLoading: _isLoading,
                        callback: null),
                  ],
                ),
              );
      }
      return _isLoading
          ? spin()
          : iconActionButton(
              context: context,
              buttonColor: 'red',
              icon: Icon(Icons.close),
              text: 'cancel order',
              order: order,
              orderCallback: cancelOrderCallback,
              // isLoading: _isLoading,
              callback: null);
    }

    if (order.status == STATUS_CONFIRMED) {
      if (widget.isSeller) {
        return _isLoading
            ? spin()
            : Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    iconActionButton(
                        context: context,
                        buttonColor: 'grey',
                        icon: Icon(Icons.arrow_back),
                        text: 'back',
                        order: order,
                        orderCallback: backCallback,
                        isTwoButtons: true,
                        // isLoading: _isLoading,
                        callback: null),
                    iconActionButton(
                        context: context,
                        buttonColor: 'green',
                        text: 'move to deliver',
                        order: order,
                        orderCallback: moveDeliverCallback,
                        isTwoButtons: true,
                        // isLoading: _isLoading,
                        callback: null),
                  ],
                ),
              );
      }
      // if (widget.isSeller) {
      //   yellowButton(
      //       context: context,
      //       buttonColor: 'red',
      //       icon: Icon(Icons.close),
      //       text: 'cancel',
      //       order: order,
      //       orderCallback: cancelOrderCallback,
      //       // isLoading: _isLoading,
      //       callback: null);
      // }

      // return iconActionButton(
      //     context: context,
      //     buttonColor: 'red',
      //     icon: Icon(Icons.close),
      //     text: 'cancel',
      //     order: order,
      //     orderCallback: cancelOrderCallback,
      //     isTwoButtons: true,
      //     // isLoading: _isLoading,
      //     callback: null);
      // return Container(); //  Do nothing
    }
    if (order.status == STATUS_TODELIVER) {
      if (widget.isSeller) {
        return _isLoading
            ? spin()
            : Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    iconActionButton(
                        context: context,
                        buttonColor: 'grey',
                        icon: Icon(Icons.arrow_back),
                        text: 'back',
                        order: order,
                        orderCallback: backCallback,
                        isTwoButtons: true,
                        // isLoading: _isLoading,
                        callback: null),
                    iconActionButton(
                        context: context,
                        buttonColor: 'green',
                        text: 'complete',
                        order: order,
                        orderCallback: completeCallback,
                        isTwoButtons: true,
                        // isLoading: _isLoading,
                        callback: null),
                  ],
                ),
              );
      }
    }

    if (order.status == STATUS_TODELIVER ||
        order.status == STATUS_CONFIRMED ||
        order.status == STATUS_CANCELLED) {
      return Container(); //  Do nothing
    }

    if (order.rating != 0.0 || order.rating != 0) {
      return Center(
          child: RatingBar.builder(
        initialRating: order.rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        ignoreGestures: true,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          print(rating);
        },
      ));
    }

    if (order.status == STATUS_COMPLETED && userController.isBuyer()) {
      return iconActionButton(
          context: context,
          // buttonColor: 'red',
          // icon: Icon(Icons.close),
          text: 'Rate Order',
          order: order,
          orderCallback: rateOrder,
          isLoading: false,
          callback: null);
    }

    return Container(); //  Do nothing

    // return iconActionButton(
    //     context: context,
    //     // buttonColor: 'red',
    //     // icon: Icon(Icons.close),
    //     text: 'Rate Order',
    //     order: order,
    //     orderCallback: rateOrder,
    //     isLoading: false,
    //     callback: null);
  }

  Widget showOrder(Order order) {
    Product product = order.orderItems![0].product!; //  Get the first item
    product.qty = order.orderItems![0].quantity!;

    String shipAddress = order.shippingAddress!.streetAddress! +
        ' ' +
        order.shippingAddress!.barangay! +
        ' ' +
        order.shippingAddress!.city! +
        ' ' +
        order.shippingAddress!.province!;

    return Container(
      // decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.all(Radius.circular(5))),
      child: ListView(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 10.0),
              child: userAccount(
                  context, widget.isSeller ? order.buyer : order.seller,
                  putActive: false,
                  isProfile: true,
                  messageIcon: true,
                  width: 25,
                  height: 25)),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            child: singleProduct(context, product, priceFontsize: 14),
          ),
          line(1),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text('Payment Details', style: ThemeText.yellowLabel)),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 15),
            child: paymentButton(context, order.creditCard!.cardType,
                paymentMethod: order.paymentMethod!,
                selectedCard: order.creditCard!,
                paid: true,
                callback: null),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: arrowLinkButton(context,
                height: 75,
                contentHeight: 28,
                title: 'Ship to: ' +
                    order.shippingAddress!.name! +
                    ' ' +
                    order.shippingAddress!.phone!,
                boldTitle: true,
                subtitle: shipAddress),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: orderTotal(context, order: order),
          ),
          arrowLinkButton(context,
              height: 50,
              // color: Colors.white,
              title: order.statusMessage,
              callback: null),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 15.0, 0, 13),
              child: actionButton(order)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTopWithBack(context,
          isMain: false, title: 'Order#' + widget.order.number.toString()),
      body: new Container(
          padding: const EdgeInsets.all(28.0), child: showOrder(widget.order)),
    );
  }
}
