import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/OrderController.dart';
import 'package:magri/models/address.dart';
import 'package:magri/models/order_item.dart';
import 'package:magri/services/base_client.dart';
import 'package:magri/services/paymaya/payment_method.dart';
import 'package:magri/widgets/modals/order_confirmed_modal.dart';
import 'package:magri/models/changenotifiers/change_notifier_payment.dart';
import 'package:magri/models/credit_card.dart';
import 'package:magri/models/order.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/services/paymaya.dart';
import 'package:magri/widgets/pages/account/account_address.dart';
import 'package:magri/widgets/pages/wallet/payment_methods.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/paymaya_view.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:magri/widgets/modals/add_basket_modal.dart';
import 'package:magri/widgets/pages/message/view_chat.dart';
import 'package:magri/widgets/pages/view_profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/userController.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class ConfirmOrder extends StatefulWidget {
  final Product? product;
  ConfirmOrder({this.product});
  @override
  State<StatefulWidget> createState() => new _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  final OrderController orderController = Get.put(OrderController());
  final UserController userController = Get.put(UserController());

  bool isLoading = false;

  bool _checkoutButtonLoading = false;

  double progress = 0.2;

  CarouselController buttonCarouselController = CarouselController();

  Auth auth = new Auth();

  Paymaya paymaya = new Paymaya();
  String? _paymayaCustomerId;

  String? _shipTo;
  String? _shipAddress = '';

  CreditCard? _selectedCard;
  // int? _selectedCardIndex = 0; // Or use default
  String? _cardType;

  Address? _selectedAddress;

  double _shippingFee = 0.0;

  Product? _product;

  User? _seller;

  bool _showBuyNow = false;

  bool _showCheckoutButton = false;

  // String _title = 'Select Payment Method';
  String _title = 'Cash on delivery';

  String _subtitle = 'COD';

  String _paymentMethod = paymentMethodCOD;

  double _magriWalletAmount = 0.0;

  @override
  void initState() {
    super.initState();

    currentFile('confirm_order.dart');

    getUser();

    setState(() {
      _product = widget.product;
      _seller = _product!.user;
    });

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
          // getCustomerCards(_paymayaCustomerId!);
        }

        getDefaultAddress();
      });
    });
    print('auth');
  }

  void getCustomerCards(String customerId) async {
    print('getCustomerCards');
    paymaya.getCustomerCards(customerId: customerId).then((dataItems) {
      if (!mounted) {
        return;
      }

      print(dataItems.toString());
      setState(() {
        if (dataItems != null) {
          Provider.of<ChangeNotifierPayment>(context, listen: false)
              .clearVaultedCreditCards();
          dataItems.forEach((item) {
            Provider.of<ChangeNotifierPayment>(context, listen: false)
                .addSelectedCard(CreditCard.fromMap(item).isDefault);

            // If we have default card
            if (CreditCard.fromMap(item).isDefault!) {
              _selectedCard = CreditCard.fromMap(item);
              if (_selectedCard!.cardType == 'master') {
                _cardType = 'MasterCard';
              }
              if (_selectedCard!.cardType == 'visa') {
                _cardType = 'Visa';
              }
            }

            Provider.of<ChangeNotifierPayment>(context, listen: false)
                .addCard(CreditCard.fromMap(item));
          });

          getDefaultAddress();
        }
      });
    });
  }

  _navigateCreatePayment(BuildContext context, {required double amount}) async {
    CreditCard card = _selectedCard!;
    var tokenId = card.token;

    var cardData =
        await paymaya.createPayment(paymentTokenId: tokenId, amount: amount);

    print(cardData['cardTokenId']);
    print(cardData['verificationUrl']);

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
        var status = await paymaya.getStatus(result['checkoutId']);

        if (status['status'] == 'PAYMENT_SUCCESS') {
          processOrder(_paymentMethod, result['checkoutId']);
        }
      }
    } else {
      print('cancelled');
      setState(() {
        _checkoutButtonLoading = false;
        print('payment cancelled');
      });
    }
  }

  _navigateCheckout(BuildContext context, {required double amount}) async {
    var cardData = await paymaya.checkout(amount: amount);

    print(cardData);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PayMayaView(
                type: 'verify',
                redirectUrl: cardData['redirectUrl'],
                checkoutId: cardData['checkoutId'],
              )),
    );

    // User? user = userController.user;

    // print(user!.email);

    if (result != null) {
      if (result['result'] == 'success') {
        // If success
        print('payment success');
        print(result);
        var status = await paymaya.getStatus(result['checkoutId']);

        if (status['status'] == 'PAYMENT_SUCCESS') {
          processOrder(_paymentMethod, result['checkoutId']);
        } else {
          setState(() {
            _checkoutButtonLoading = false;
            print('payment success cancelled');
          });
        }
      }
    } else {
      print('cancelled');
      setState(() {
        _checkoutButtonLoading = false;
        print('payment cancelled');
      });
    }
  }

  void processOrder(String paymentMethod, String? checkoutId) {
    // Process order
    OrderItem orderItem = OrderItem('', 0, _product!, _product!.qty, '0');
    sendOrder(orderItem,
            paymentMethod: paymentMethod,
            checkoutId: checkoutId.toString(),
            addressId: _selectedAddress!.id,
            shippingFee: _shippingFee)
        .then((value) {
      setState(() {
        _checkoutButtonLoading = false;
        print('payment confirmed');
      });

      Navigator.of(context).popUntil((route) => route.isFirst);

      orderConfirmedModal(context, _product!);
    });

    // print(result.toString());
  }

  // void checkAuth() {
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     Provider.of<ChangeNotifierPayment>(context, listen: false)
  //         .checkAuth(widget.checkoutId);
  //   });
  // }

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

  Widget buyNow(User _seller, Product product) {
    if (_showBuyNow == false) {
      return Container();
    }
    return Container(
        //color: Colors.red,
        child: Card(
            margin: EdgeInsets.all(16),
            elevation: 5,
            child: Container(
                height: 50,
                margin: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  //color: Colors.green[900],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('tap profile');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewProfile(user: _seller)));
                      },
                      child: Icon(Icons.account_circle_outlined),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('tap chat');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewChat(user: _seller)));
                      },
                      child: Icon(Icons.mark_chat_read_outlined),
                    ),
                    SizedBox(
                      width: 150.0,
                      height: 35.0,
                      child: new ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          //elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          primary: Colors.green[700],
                        ),
                        child: new Text('Buy Now',
                            style: new TextStyle(
                                fontSize: 12.0, color: Colors.white)),
                        onPressed: () {
                          addBasketModal(context, product);
                        },
                      ),
                    ),
                  ],
                ))));
  }

  void openPaymentDetails() {
    //
    print('openPaymentDetails');
    _navigatePaymentDetails(context);
  }

  _navigatePaymentDetails(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => AddCreditCard(
    //             selectedCardIndex: _selectedCardIndex,
    //             paymayaCustomerId: _paymayaCustomerId,
    //           )),
    // );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentMethods()),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success then reload the home page data
        print('payment method: ' + result['payment_method']);

        setState(() {
          _paymentMethod = result['payment_method'];
        });

        // If Card
        if (result['payment_method'] == 'card') {
          // print('card details ...' + result['selectedCard'].first6);

          // setState(() {
          //   _selectedCard = result['selectedCard'];
          //   // _selectedCardIndex = result['selectedCardIndex'];

          //   // Make true if Address is also selected
          if (_shipTo != null) {
            _showCheckoutButton = true;
          }

          //   if (_selectedCard!.cardType == 'master') {
          //     _cardType = 'MasterCard';
          //   }
          //   if (_selectedCard!.cardType == 'visa') {
          //     _cardType = 'Visa';
          //   }
          // });
          _title = 'Credit Card';
          _subtitle = 'Pay via Credit Card';
        }

        // If Magri Wallet
        if (result['payment_method'] == paymentMethodMagriWallet) {
          setState(() {
            _title = 'Magri Wallet';
            _subtitle = 'Bal: Php ' + result['balance'].toString();
            _selectedCard = null;
            _magriWalletAmount =
                double.parse(result['balance'].toString().replaceAll(',', ''));
          });
          print(paymentMethodMagriWallet);
        }

        // COD
        if (result['payment_method'] == paymentMethodCOD) {
          setState(() {
            _title = 'Cash on delivery';
            _subtitle = 'COD';
            _selectedCard = null;
            // Make true if Address is also selected
            if (_shipTo != null) {
              _showCheckoutButton = true;
            }
          });
          print(paymentMethodCOD);
        }
      }
    }
  }

  void getDefaultAddress() async {
    print('getDefaultAddress');

    BaseClient().get('/addresses').then((dataItems) {
      setState(() {
        if (dataItems != null) {
          dataItems.forEach((item) {
            if (Address.fromMap(item).isDefault!) {
              var address = Address.fromMap(item);
              _selectedAddress = address;
              _shipTo = address.name;
              _shipAddress = address.streetAddress! +
                  ' ' +
                  address.barangay! +
                  ' ' +
                  address.city! +
                  ' ' +
                  address.province!;

              // Make true if Address is also selected
              if (_selectedCard != null) {
                _showCheckoutButton = true;
              }
              if (_paymentMethod == paymentMethodMagriWallet ||
                  _paymentMethod == paymentMethodCOD) {
                _showCheckoutButton = true;
              }
            }
          });
        }
      });
    });
    // setState(() {
    //   _selectedAddress = result['address'];
    //   _shipTo = result['address'].name;
    //   _shipAddress = result['address'].streetAddress +
    //       ' ' +
    //       result['address'].barangay +
    //       ' ' +
    //       result['address'].city +
    //       ' ' +
    //       result['address'].province;

    //   // Make true if Address is also selected
    //   if (_selectedCard != null) {
    //     _showCheckoutButton = true;
    //   }
    //   if (_paymentMethod == paymentMethodMagriWallet ||
    //       _paymentMethod == paymentMethodCOD) {
    //     _showCheckoutButton = true;
    //   }
    // });
  }

  void openShippingDetails() {
    //
    print('openShippingDetails');
    _navigateAccountAddress(context);

    // Navigate to address page
  }

  _navigateAccountAddress(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AccountAddress(
                method: 'select-address',
              )),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success then reload the home page data
        setState(() {
          _selectedAddress = result['address'];
          _shipTo = result['address'].name;
          _shipAddress = result['address'].streetAddress +
              ' ' +
              result['address'].barangay +
              ' ' +
              result['address'].city +
              ' ' +
              result['address'].province;

          // Make true if Address is also selected
          if (_selectedCard != null) {
            _showCheckoutButton = true;
          }
          if (_paymentMethod == paymentMethodMagriWallet ||
              _paymentMethod == paymentMethodCOD ||
              _paymentMethod == paymentMethodCard) {
            _showCheckoutButton = true;
          }
        });
        print('success---id: ' + result['address'].id.toString());
      }
    }
  }

  void checkout() {
    print('checkout');
    setState(() {
      _checkoutButtonLoading = true;
    });
    double orderAmount =
        double.parse(widget.product!.price) * widget.product!.qty +
            _shippingFee;
    if (_paymentMethod == paymentMethodCard) {
      // _navigateCreatePayment(context, amount: orderAmount);
      _navigateCheckout(context, amount: orderAmount);
    }

    if (_paymentMethod == paymentMethodMagriWallet) {
      print('magri wallet method');
      if (_magriWalletAmount < orderAmount) {
        print('cant process');

        Fluttertoast.showToast(
            msg: 'Your wallet amount is not enough!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          _checkoutButtonLoading = false;
        });
        return;
      }

      processOrder(_paymentMethod, '');
    }

    if (_paymentMethod == paymentMethodCOD) {
      print(paymentMethodCOD);
      processOrder(_paymentMethod, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<ChangeNotifierUser>();

    // If not the same as the current user then show follow and message
    if (_seller!.id != user.getUserId()) {
      setState(() {
        _showBuyNow = true;
      });
    }

    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: 'Confirm Order'),
      backgroundColor: body_color,
      body: new Container(
        padding: EdgeInsets.fromLTRB(27, 16, 27, 16),
        child: ListView(children: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text('Seller Details', style: ThemeText.yellowLabel)),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: userAccount(context, _seller, messageIcon: true)),
          // line(5),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text('Item Summary', style: ThemeText.yellowLabel)),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: singleProduct(context, _product!),
          ),
          line(1),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text('Payment Details', style: ThemeText.yellowLabel)),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 15),
            child: paymentButton(context, _cardType,
                title: _title,
                subTitle: _subtitle,
                paymentMethod: _paymentMethod,
                selectedCard: _selectedCard,
                callback: openPaymentDetails),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: arrowLinkButton(context,
                title:
                    _shipTo != null ? 'Ship to: ' + _shipTo! : 'Select Address',
                subtitle: _shipAddress!,
                callback: openShippingDetails),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 34),
            child: orderTotal(context,
                order: Order(
                    id: 1,
                    subTotal: double.parse(_product!.price) * _product!.qty,
                    totalAmount: double.parse(_product!.price) * _product!.qty +
                        _shippingFee,
                    shippingFee: _shippingFee)),
          ),

          _checkoutButtonLoading
              ? spin(color: yellowColor)
              : iconActionButton(
                  context: context,
                  text: 'checkout',
                  // productCallback: productCallback,
                  enable: _showCheckoutButton,
                  isLoading: _checkoutButtonLoading,
                  callback: checkout)
        ]),
      ),
    );
  }
}
