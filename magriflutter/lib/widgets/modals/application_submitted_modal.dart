import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magri/models/order.dart';
import 'package:magri/widgets/partials/buttons.dart';

void applicationSubmittedModal(BuildContext context) {
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
              height: 406,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.back();
                          Get.back();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(right: 29),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ))
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/verify_icon.png',
                          height: 103,
                          width: 84,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Text(
                      'APPLICATION SUBMITTED',
                      style: TextStyle(fontSize: 22),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    SizedBox(
                        width: 200,
                        child: Text(
                            'Please allow at least 30 minutes for us to review your application. An OTP will arrive to to your mobile number +63 995 123 4567 when you account has been verified.')),
                    Padding(padding: EdgeInsets.only(top: 58)),
                    SafeArea(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconActionButton(
                            context: context,
                            buttonColor: 'green',
                            text: 'continue',
                            // product: product,
                            // order: order,
                            // orderCallback: orderCallback,
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

void orderCallback(BuildContext? context, Order? order) {
  print('orderCallback' + order!.rating.toString());
  rateOrder(order.id!.toString(), order.rating, order.ratingMessage);

  Navigator.pop(context!);
}

void callback() {
  print('callback');
  Get.back();
  Get.back();
  Get.back();
}
