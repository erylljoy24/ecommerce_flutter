import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:magri/models/changenotifiers/change_notifier_payment.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/services/paymaya.dart';
import 'package:magri/services/paymaya/payment_method.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:magri/widgets/partials/partial_payment_method.dart';
import 'package:magri/widgets/partials/paymaya_view.dart';
import 'package:provider/provider.dart';

import '../my_wallet.dart';

class TopUpMethod extends StatefulWidget {
  final double? topUpAmount;
  final String? returnTo; // return to page
  TopUpMethod({this.topUpAmount, this.returnTo});
  @override
  State<StatefulWidget> createState() => new _TopUpMethodState();
}

class _TopUpMethodState extends State<TopUpMethod> {
  bool _isLoading = false;

  bool _showAddCard = false;

  List<PaymentMethod> _paymentMethods = [];

  dynamic _checkoutItems;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Auth auth = new Auth();

  Paymaya paymaya = new Paymaya();

  String? _paymayaCustomerId;

  @override
  void initState() {
    super.initState();

    checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Get auth so that we can get if user have paymaya customer id already
  void checkAuth() async {
    auth.signInToken().then((value) {
      print('auth ok');
      auth.getUserData().then((userData) {
        setState(() {
          _paymayaCustomerId = userData['paymaya_customer_id'];
        });

        if (_paymayaCustomerId != null) {
          getCustomerCards(_paymayaCustomerId!);
        }
      });
      //print(data);
    });
    print('auth');
  }

  _navigatePay(BuildContext context) async {
    var checkoutData = await paymaya.prepareCheckout(
        type: 'topup', topUpAmount: widget.topUpAmount);

    print(checkoutData.toString());

    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PayMayaView(
                type: 'topup',
                topUpAmount: widget.topUpAmount,
                redirectUrl: checkoutData['redirectUrl'],
                checkoutId: checkoutData['checkoutId'],
              )),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success
        print('payment success');
        print(result.toString());
      }
    } else {
      print('cancelled');
    }

    // If widget.returnTo is to checkout
    if (widget.returnTo == 'checkout') {
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             Wallet(checkoutId: checkoutData['checkoutId'])),
      //     ModalRoute.withName('/'));
      Provider.of<ChangeNotifierPayment>(context, listen: false)
          .checkAuth(checkoutData['checkoutId']);
      Navigator.pop(context);
      Navigator.pop(context);

      print('checkout');
    } else {
      // Then update the wallet amount
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  MyWallet(checkoutId: checkoutData['checkoutId'])),
          ModalRoute.withName('/'));
    }

    // Navigator.of(context).pushNamedAndRemoveUntil(
    //     '/account/wallet', ModalRoute.withName('/'),
    //     arguments: {"_checkoutId": _checkoutId});
  }

  _navigateStoreCard(BuildContext context, String number) async {
    // If no exiting _paymayaCustomerId then we create one
    if (_paymayaCustomerId == null) {
      var customerData = await paymaya.createCustomer(customer: {
        "firstName": "Name",
      });

      print(customerData['id']);

      setState(() {
        _paymayaCustomerId = customerData['id'];
      });

      // Store the customer id to database
      var stored = await storePaymayaCustomerId(customerData['id']);

      if (stored == false) {
        // Error
      }
    }

    // Create payment token from card details
    var checkoutData = await paymaya.createPaymentToken(card: {
      "number": number.replaceAll(' ', ''),
      "expMonth": expiryDate.substring(0, 2), // month 01
      "expYear":
          '20' + expiryDate.substring(expiryDate.length - 2), // year 2025
      "cvc": cvvCode
    });

    // 4123 4501 3100 1381
    print(checkoutData['paymentTokenId']);

    var cardData = await paymaya.createCustomerCards(
        customerId: _paymayaCustomerId!,
        paymentTokenId: checkoutData['paymentTokenId'],
        isDefault: true);

    print(cardData['cardTokenId']); // verificationUrl
    print(cardData);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PayMayaView(
                type: 'verify',
                redirectUrl: cardData['verificationUrl'],
                checkoutId: cardData['id'],
              )),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success
        print('payment success');
        print(result.toString());
      }
    } else {
      print('cancelled');
    }

    // Then update the wallet amount
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             Wallet(checkoutId: checkoutData['checkoutId'])),
    //     ModalRoute.withName('/'));
  }

  _navigateCreatePayment(
      BuildContext context, String tokenId, double amount) async {
    var tokenId =
        '9gTts8ocMnVzi47sylxOG9wKrCq09DFpqHCLiGD6UipFUnQyR9E6bno8Jvmqj8H6a7ecl2g8dKgAiolxIfRaYBacrHfygnu0Ogemy1F4ZJ8sXE27IgDhJdQNx4wCBUm44ut6QBqKoXShx7I8yrY0kSzg9wkFDoHOBvWki9cqwo';

    var cardData =
        await paymaya.createPayment(paymentTokenId: tokenId, amount: amount);

    //print(cardData['cardTokenId']);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PayMayaView(
                type: 'verify',
                redirectUrl: cardData['verificationUrl'],
                checkoutId: cardData['id'],
              )),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success
        print('payment success');
        print(result.toString());
      }
    } else {
      print('cancelled');
    }
  }

  void getCustomerCards(String customerId) async {
    // var cards = await paymaya.getCustomerCards(
    //     customerId: 'd9b91315-ec58-4685-81f0-a6b52947cb26');

    var cards = await paymaya.getCustomerCards(customerId: customerId);

    print(cards.toString());
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: body_color,
          title: Text(
            'Cash in Method',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          leading: popArrow(context),
          bottomOpacity: 0.0,
        ),
        backgroundColor: body_color,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Under development. UI needed.'),
              //PartialPaymentMethod(null),
              new ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.green[700]!)),
                  primary: Colors.white,
                ),
                child: new Text(
                    'Confirm Top Up ' + widget.topUpAmount.toString(),
                    style: new TextStyle(fontSize: 12.0, color: Colors.black)),
                onPressed: () {
                  _navigatePay(context);
                  // Pay
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => PayMayaView(
                  //         type: 'topup', topUpAmount: widget.topUpAmount)));
                },
              ),
              // new RaisedButton(
              //   //elevation: 5.0,
              //   shape: new RoundedRectangleBorder(
              //       borderRadius: new BorderRadius.circular(20.0),
              //       side: BorderSide(color: Colors.green[700])),
              //   color: Colors.white,
              //   child: new Text('Add Card',
              //       style: new TextStyle(fontSize: 12.0, color: Colors.black)),
              //   onPressed: () async {
              //     _navigateStoreCard(context);
              //   },
              // ),

              // CreditCardWidget(
              //   cardNumber: cardNumber,
              //   expiryDate: expiryDate,
              //   cardHolderName: cardHolderName,
              //   cvvCode: cvvCode,
              //   showBackView: isCvvFocused,
              //   obscureCardNumber: true,
              //   obscureCardCvv: true,
              // ),
              _showAddCard
                  ? CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: false,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      themeColor: Colors.blue,
                      cardNumberDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Number',
                        //hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      //numberValidationMessage: 'Car Number is required',
                      expiryDateDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                      ),
                      //dateValidationMessage: 'Expiry Date is required',
                      cvvCodeDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CVV',
                        //hintText: 'XXX',
                      ),
                      //cvvValidationMessage: 'CVV is required',
                      cardHolderDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Holder',
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    )
                  : Container(),
              _showAddCard
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        primary: const Color(0xff1b447b),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        child: const Text(
                          'Add Card',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'halter',
                            fontSize: 14,
                            package: 'flutter_credit_card',
                          ),
                        ),
                      ),
                      onPressed: () {
                        print(cardNumber);
                        //print(expiryDate);
                        // print(expiryDate.substring(0, 2));
                        // print('20' + expiryDate.substring(expiryDate.length - 2));
                        if (formKey.currentState!.validate()) {
                          print('valid!');
                          _navigateStoreCard(context, cardNumber);
                        } else {
                          print('invalid!');
                        }
                      },
                    )
                  : Container()
            ],
          ),
        ));
  }
}
