import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/widgets/pages/tabs/my_orders.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:path/path.dart';

void contributionAddedModal(BuildContext context) {
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
                      'Contribution Added!',
                      style: TextStyle(fontSize: 22),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(28.0, 0, 28.0, 0),
                      child: Text(
                        'Please wait until the Drops completion to sell the product to the Drop Creator',
                        style: TextStyle(color: Colors.grey, height: 2),
                      ),
                    ),
                    Spacer(),
                    line(2),
                    // Padding(
                    //     padding: EdgeInsets.fromLTRB(28.0, 0, 28.0, 0),
                    //     child: userAccount(context, product.user,
                    //         messageIcon: true)),
                    Spacer(),
                    SafeArea(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconActionButton(
                            context: context,
                            text: 'my contributions',
                            // productCallback: productCallback,
                            // callback: callback,
                            popCallback: popCallback),
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
}

void popCallback(BuildContext? context) {
  Navigator.pop(context!);

  // pop and go to index 2 of tab
  Navigator.pop(context, {"result": "success", "go_index": 2});

  // print('callback');
}

// void callback() {
//   Navigator.pop(context!);
//   print('callback');
// }
