import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/widgets/pages/tabs/my_orders.dart';
import 'package:magri/widgets/pages/tabs/view_order.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/models/order_item.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:magri/util/colors.dart';

void orderConfirmedModal(BuildContext context, Product product,
    [int? currentQuantity]) {
  int quantity = currentQuantity ?? 1;
  product.qty = quantity;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
        return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 473,
              // padding: EdgeInsets.all(29.0),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 40)),
                    Image.asset(
                      'assets/images/cart-confirmed.png',
                      height: 97,
                      width: 97,
                      // color: Colors.green,
                    ),
                    Padding(padding: EdgeInsets.only(top: 25.5)),
                    Text(
                      'Order has been sent!',
                      style: TextStyle(fontSize: 22),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(28.0, 0, 28.0, 0),
                      child: Text(
                        'Please wait until your order is ready to be shipped, you can chat the Seller for more details',
                        style: TextStyle(color: Colors.grey, height: 2),
                      ),
                    ),
                    Spacer(),
                    line(2),
                    Padding(
                        padding: EdgeInsets.fromLTRB(28.0, 0, 28.0, 0),
                        child: userAccount(context, product.user,
                            messageIcon: true)),
                    Spacer(),
                    SafeArea(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconActionButton(
                            context: context,
                            text: 'my orders',
                            product: product,
                            productCallback: productCallback,
                            callback: callback),
                      ],
                    ))
                  ],
                ),
              ),
            ));
      });
    },
  );
}

void productCallback(BuildContext? context, Product? product) {
  Navigator.of(context!)
      .push(MaterialPageRoute(builder: (context) => MyOrders()));
  print('callback2');

  // print('callback' + product!.qty.toString());
  // if (product.qty > 0) {
  //   Navigator.of(context!).push(MaterialPageRoute(
  //       builder: (context) => ConfirmOrder(product: product)));
  // }
}

void callback() {
  // Navigator.of(context!).pushNamedAndRemoveUntil(
  //     '/account/wallet', ModalRoute.withName('/'),
  //     arguments: {});

  print('callback');
}
