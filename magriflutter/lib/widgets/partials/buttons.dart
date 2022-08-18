import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/models/credit_card.dart';
import 'package:magri/models/order.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/services/paymaya/payment_method.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';

Color selectedColor(String color) {
  if (color == 'yellow') {
    return buttonYellowColor;
  }
  if (color == 'green') {
    return buttonGreenColor;
  }
  if (color == 'red') {
    return buttonRedColor;
  }

  if (color == 'grey') {
    return Colors.grey;
  }

  return buttonGreenColor;
}

Widget iconActionButton({
  BuildContext? context,
  required String text,
  Widget? icon,
  String buttonColor = 'yellow',
  VoidCallback? callback,
  Product? product,
  Order? order,
  User? seller,
  bool isLoading = false,
  bool isTwoButtons = false,
  bool enable = true,
  Function(
    BuildContext?,
  )?
      popCallback,
  Function(BuildContext?, Product?)? productCallback,
  Function(BuildContext?, Order?)? orderCallback,
  Function(BuildContext?, User?)? userCallback,
}) {
  double? boxWidth = isLoading ? 50 : MediaQuery.of(context!).size.width / 1.2;

  if (isTwoButtons) {
    boxWidth = null;
  }

  return SizedBox(
      width: boxWidth,
      height: 49.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(color: Colors.white),
          primary: selectedColor(buttonColor),
          shape: !enable
              ? null
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(color: selectedColor(buttonColor))),
        ),
        onPressed: !enable
            ? null
            : () async {
                if (callback != null) {
                  callback.call();
                }
                if (productCallback != null) {
                  productCallback.call(context, product);
                }
                if (orderCallback != null) {
                  orderCallback.call(context, order);
                }
                if (userCallback != null) {
                  userCallback.call(context, seller);
                }
                if (popCallback != null) {
                  popCallback.call(context);
                }
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.check),
            icon != null
                ? icon
                : Icon(Icons.check_box,
                    color: enable ? null : Colors.grey[100]),
            Padding(padding: EdgeInsets.only(right: 12)),
            new Text(upperCase(text),
                style: new TextStyle(fontSize: 16.0, color: Colors.white))
          ],
        ),
      ));
}

Widget arrowLinkButton(BuildContext context,
    {Widget? image,
    String title = '',
    bool? boldTitle = false,
    String subtitle = '',
    Color? titleColor,
    Color? color,
    double? height,
    double? contentHeight = 12.0,
    VoidCallback? callback}) {
  return GestureDetector(
      onTap: () {
        if (callback != null) {
          callback.call();
        }
      },
      child: Container(
          height: height != null ? height : 62,
          padding: EdgeInsets.all(15),
          color: color != null ? color : Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  // productImage(product, width: width, height: height),
                  (image != null) ? image : Container(),
                  // This is on add to cart
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: TextStyle(
                                  color: titleColor != null
                                      ? titleColor
                                      : Colors.grey[900],
                                  fontSize: 12,
                                  fontWeight: boldTitle!
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.8,
                            // If subtitle is blank then make height 0
                            height: subtitle == '' ? 0 : contentHeight,
                            child: Text(subtitle,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ),
                        ],
                      ))
                ],
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.green[700],
              )
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     Text('xxxx', style: TextStyle(color: Colors.green, fontSize: 20)),
              //   ],
              // ),
            ],
          )));
}

Widget paymentButton(BuildContext context, String? cardType,
    {String title = '',
    String subTitle = '',
    String paymentMethod = 'card',
    bool paid = false,
    CreditCard? selectedCard,
    VoidCallback? callback}) {
  Widget? image;

  if (selectedCard != null) {
    image = SvgPicture.asset(
      'assets/images/wallet/' + selectedCard.cardType.toString() + '.svg',
      height: 18,
      width: 44,
    );
    title = 'Credit Card: ' + cardType.toString();
    subTitle = '' +
        selectedCard.first6.toString() +
        ' **** ' +
        selectedCard.last4.toString();
  }

  if (paymentMethod == paymentMethodMagriWallet) {
    title = 'Magri Wallet';
    if (paid) {
      subTitle = '';
    }
    image = SvgPicture.asset(
      'assets/images/wallet/Magri Wallet.svg',
      height: 24.6,
      width: 33.6,
      color: Colors.green,
    );
  }

  if (paymentMethod == paymentMethodCOD) {
    title = 'Cash on delivery';
    if (paid) {
      subTitle = 'COD';
    }
    image = Image.asset(
      'assets/images/cash.png',
      height: 24.6,
      width: 33.6,
    );
  }

  return arrowLinkButton(
    context,
    image: image == null ? null : SizedBox(width: 44, child: image),
    title: title,
    subtitle: subTitle,
    callback: callback,
    // callback: openPaymentDetails,
  );
}

Widget orderTotal(BuildContext context, {required Order order}) {
  return Container(
      height: 116,
      // padding: EdgeInsets.all(15),
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 62,
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Sub-Total'),
                    Text(
                      'P ' + order.subTotal.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shipping/Delivery Cost'),
                    Text(
                      'P ' + order.shippingFee.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          orderTotalGreen(order, 'total'),
        ],
      ));
}

Widget orderTotalGreen(Order order, String totalText, {Color? color}) {
  return Container(
    padding: EdgeInsets.all(15),
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          upperCase(totalText),
          style: order.status == 'cancelled'
              ? textStyleCancelled()
              : textStyleNormal(),
        ),
        Text(
          'P' + order.totalAmount.toString(),
          style: order.status == 'cancelled'
              ? textStyleCancelled()
              : textStyleNormal(),
        ),
      ],
    ),
    color: color != null ? color : greenColor,
  );
}

TextStyle textStyleNormal() => TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

TextStyle textStyleCancelled() => TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.lineThrough,
    decorationThickness: 4.0);
