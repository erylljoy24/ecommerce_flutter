import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/models/order_item.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:magri/util/colors.dart';

void addBasketModal(BuildContext context, Product product,
    [int? currentQuantity]) {
  int quantity = currentQuantity ?? 1;
  bool buyNowEnable = true;
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
        final quantityController =
            TextEditingController(text: quantity.toString());
        quantityController.selection = TextSelection.fromPosition(
            TextPosition(offset: quantityController.text.length));

        return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 300,
              padding: EdgeInsets.all(29.0),
              //color: Colors.grey[100],
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          //
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ))
                          ],
                        )),
                    singleProduct(context, product,
                        width: 72, height: 72, isPriceStocks: true),
                    Spacer(),
                    line(2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Quantity',
                          style: ThemeText.greyLabel,
                        ),
                        Row(
                          children: [
                            new Container(
                              height: 40,
                              // width: 40,
                              //color: Colors.red,
                              decoration: BoxDecoration(
                                  // color: Colors.grey[300],
                                  // border: Border.all(
                                  //     //color: Colors.red[500],
                                  //     ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: new IconButton(
                                  color: Colors.transparent,
                                  icon: SvgPicture.asset(
                                    'assets/images/minus.svg',
                                    height: 21.6,
                                    width: 21.6,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    print('tap -');

                                    //This sets modal state
                                    if (quantity != 0) {
                                      setModalState(() {
                                        quantity--;
                                        product.qty = quantity;
                                      });
                                    }
                                  }),
                            ),
                            Container(
                              width: 100,
                              height: 50,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0.0, 10, 0.0),
                                child: new TextFormField(
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  keyboardType: TextInputType.number,
                                  controller: quantityController,
                                  autofocus: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  decoration: new InputDecoration(
                                    labelStyle:
                                        new TextStyle(color: Colors.black),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2.0),
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: button_beige_text_color),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setModalState(() {
                                      quantity = int.parse(val);
                                      product.qty = quantity;
                                    });
                                  },
                                  onSaved: (val) {
                                    setModalState(() {
                                      quantity = int.parse(val!);
                                    });
                                    print('saved');
                                  },
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              //color: Colors.red,
                              decoration: BoxDecoration(
                                  // color: Colors.grey[300],
                                  // border: Border.all(
                                  //     //color: Colors.red[500],
                                  //     ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: new IconButton(
                                  icon: SvgPicture.asset(
                                    'assets/images/plus.svg',
                                    height: 21.6,
                                    width: 21.6,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    print('tap +');

                                    if (product.qty == 999) {
                                      return;
                                    }

                                    //This sets modal state
                                    setModalState(() {
                                      quantity++;
                                      product.qty = quantity;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconActionButton(
                            context: context,
                            text: 'buy now',
                            product: product,
                            productCallback: productCallback,
                            enable: product.qty > 0 &&
                                product.qty <=
                                    int.parse(product.stocks.toString()),
                            callback: callback),
                      ],
                    )
                  ],
                ),
              ),
            ));
      });
    },
  );
}

void productCallback(BuildContext? context, Product? product) {
  print('callback' + product!.qty.toString());
  if (product.qty > 0) {
    Navigator.of(context!).push(MaterialPageRoute(
        builder: (context) => ConfirmOrder(product: product)));
  }
}

void callback() {
  print('callback');
}

Future<OrderItem?> processSendOrder(OrderItem orderItem) async {
  var order = await sendOrder(orderItem, paymentMethod: 'credit-card');

  if (order['id'] != 0) {
    print('orderId:' + order['id'].toString());

    orderItem.orderId = order['id'];
    orderItem.orderNumber = order['number'];
    orderItem.total =
        (double.parse(orderItem.product!.price) * orderItem.quantity!)
            .toString();

    return orderItem;
  }

  return null;
}
