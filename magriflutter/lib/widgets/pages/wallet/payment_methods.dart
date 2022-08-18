import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/models/credit_card.dart';
import 'package:magri/services/paymaya/payment_method.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/wallet/add_credit_card.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/changenotifiers/change_notifier_payment.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class PaymentMethods extends StatefulWidget {
  final Product? product;
  PaymentMethods({this.product});
  @override
  State<StatefulWidget> createState() => new _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  bool isLoading = false;
  String? _paymayaCustomerId;
  int? _selectedCardIndex = 0; // Or use default
  CreditCard? _selectedCard;
  String? _cardType;

  @override
  void initState() {
    super.initState();

    currentFile('payment_methods.dart');

    getUser();

    setState(() {
      // _product = widget.product;
    });

    checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkAuth() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ChangeNotifierPayment>(context, listen: false)
          .checkAuth(null);
    });
  }

  void getUser() async {
    final SharedPreferences prefs = await _prefs;
    String? _currentUserId = await prefs.getString('userId');

    setState(() {
      _currentUserId = _currentUserId;
    });
  }

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  // void openPaymentDetails() {
  //   //
  //   print('openPaymentDetails');
  // }

  void checkout() {
    //
    print('checkout');
  }

  void payMagriWallet() {
    //TODO
    print('pay Magri Wallet');

    // Navigator.pop(context, {
    //   "payment_method": paymentMethodMagriWallet,
    //   "result": "success",
    //   "balance": Provider.of<ChangeNotifierPayment>(context, listen: false)
    //       .walletAmount!,
    //   // "selectedCard": _selectedCard,
    //   // "selectedCardIndex": _selectedCardIndex,
    //   // "cardType": _cardType
    // });
  }

  void payEWallet() {
    //TODO
    print('ewallet');
  }

  void payOverTheCounter() {
    //TODO
    print('over the counter');
  }

  void payOnlineBanking() {
    //TODO
    print('online banking');
  }

  void openPaymentCard() {
    //
    print('openPaymentCard');
    // _navigatePaymentDetails(context);
    Navigator.pop(context, {
      "payment_method": paymentMethodCard,
      "result": "success",
    });
    print('use card');
  }

  void openCOD() {
    Navigator.pop(context, {
      "payment_method": paymentMethodCOD,
      "result": "success",
    });
    print('openCOD');
  }

  _navigatePaymentDetails(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCreditCard(
                selectedCardIndex: _selectedCardIndex,
                paymayaCustomerId: _paymayaCustomerId,
              )),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success then reload the home page data
        print('card details' + result['selectedCard'].first6);

        setState(() {
          _selectedCard = result['selectedCard'];
          _selectedCardIndex = result['selectedCardIndex'];

          if (_selectedCard!.cardType == 'master') {
            _cardType = 'MasterCard';
          }
          if (_selectedCard!.cardType == 'visa') {
            _cardType = 'Visa';
          }
        });

        Navigator.pop(context, {
          "payment_method": result['payment_method'],
          "result": "success",
          "selectedCard": _selectedCard,
          "selectedCardIndex": _selectedCardIndex,
          "cardType": _cardType
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBarTopWithBack(context, isMain: false, title: 'Payment Methods'),
      backgroundColor: body_color,
      body: new Container(
        padding: EdgeInsets.fromLTRB(27, 16, 27, 16),
        child: ListView(children: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child:
                  Text('Select Payment Method', style: ThemeText.yellowLabel)),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: arrowLinkButton(context,
                image: Image.asset(
                  'assets/images/cash.png',
                  height: 24.6,
                  width: 33.6,
                ),
                title: 'Cash on Delivery',
                subtitle: 'COD',
                callback: openCOD),
          ),
          Consumer<ChangeNotifierPayment>(builder: (context, payment, child) {
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: arrowLinkButton(context,
                  image: SvgPicture.asset(
                    'assets/images/wallet/Magri Wallet.svg',
                    height: 24.6,
                    width: 33.6,
                    color: Colors.green,
                  ),
                  title: 'Magri Wallet',
                  subtitle:
                      'Bal: Php ' + payment.walletAmount! + ' (Not Available)',
                  callback: payMagriWallet),
            );
          }),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: arrowLinkButton(context,
                image: Image.asset(
                  'assets/images/credit-card-payment.png',
                  height: 24.6,
                  width: 33.6,
                ),
                title: 'Credit/Debit Card',
                subtitle: 'Add/Select Debit/Credit Card',
                callback: openPaymentCard),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: arrowLinkButton(context,
                image: Image.asset(
                  'assets/images/wallet.png',
                  height: 24.6,
                  width: 33.6,
                ),
                title: 'ePayment/eWallet',
                subtitle: 'Select eWallet(Not Available)',
                callback: payEWallet),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: arrowLinkButton(context,
                image: Image.asset(
                  'assets/images/cashier.png',
                  height: 24.6,
                  width: 33.6,
                ),
                title: 'Over-the-counter',
                subtitle: 'Select Partner Stores(Not Available)',
                callback: payOverTheCounter),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: arrowLinkButton(context,
                image: Image.asset(
                  'assets/images/cash.png',
                  height: 24.6,
                  width: 33.6,
                ),
                title: 'Online Banking',
                subtitle: 'Select Online Bank(Not Available)',
                callback: payOnlineBanking),
          ),
        ]),
      ),
    );
  }
}
