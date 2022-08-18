import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/models/changenotifiers/change_notifier_payment.dart';
import 'package:magri/models/user.dart';
import 'package:magri/models/wallet.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/services/paymaya.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/pages/wallet/add_credit_card.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'wallet/top_up.dart';

class MyWallet extends StatefulWidget {
  final String? returnTo; // return to page
  final String? checkoutId;
  final bool noBackButton;
  MyWallet({this.checkoutId, this.returnTo, this.noBackButton = false});
  @override
  State<StatefulWidget> createState() => new _ViewProductState();
}

class _ViewProductState extends State<MyWallet> {
  final UserController userController = Get.put(UserController());

  bool _isLoading = false;

  bool _isAmountLoading = false;

  String _walletAmount = '0.00';

  Auth auth = new Auth();

  Paymaya paymaya = new Paymaya();

  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();

    print('checkoutId:' + widget.checkoutId.toString());

    print('wallet.dart');

    // We can also check for an updated wallet amount via API
    //checkAuth();
    checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkAuth() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ChangeNotifierPayment>(context, listen: false)
          .checkAuth(widget.checkoutId);
    });

    setState(() {
      _wallets.add(Wallet(id: '1', name: 'My Wallet', balance: 100));
    });
  }

  // void setReturnTo() async {
  //   Provider.of<ChangeNotifierPayment>(context, listen: false)
  //       .setReturnTo(widget.returnTo);
  // }

  // Get auth so that we can get if user have paymaya customer id already
  // void checkAuth() async {
  //   setState(() {
  //     _isAmountLoading = true;
  //   });
  //   auth.signInToken().then((value) {
  //     print('auth ok');

  //     auth.getUserData().then((userData) {
  //       setState(() {
  //         _walletAmount = userData['wallet_amount'];
  //         _isAmountLoading = false;
  //       });

  //       checkStatus(widget.checkoutId);
  //     });
  //   });
  //   print('auth');
  // }

  //  4123 4501 3100 1381
  // void checkStatus(String checkoutId) async {
  //   if (checkoutId != null) {
  //     setState(() {
  //       _isAmountLoading = true;
  //     });
  //     paymaya.getStatus(checkoutId).then((paymentData) {
  //       print('Wallet: =====' + paymentData.toString());
  //       print('=====' + paymentData['id']);
  //       print('=====' + paymentData['status']);
  //       print('=====' + paymentData['amount']);
  //       if (paymentData['status'] == 'PAYMENT_SUCCESS') {
  //         var existingAmount = double.parse(_walletAmount);
  //         var successAmount = double.parse(paymentData['amount']);
  //         var totalAmount = existingAmount + successAmount;

  //         // Push the new amount to server
  //         storeNewAmount(paymentData['id'], checkoutId, paymentData['amount'])
  //             .then((success) {
  //           if (success) {
  //             setState(() {
  //               // amount to existing one
  //               _walletAmount = totalAmount.toString();
  //             });
  //           }
  //           setState(() {
  //             _isAmountLoading = false;
  //           });
  //         });
  //       } else {
  //         setState(() {
  //           _isAmountLoading = false;
  //         });
  //         // If failed
  //         Fluttertoast.showToast(
  //             msg: 'Payment failed please try again.',
  //             toastLength: Toast.LENGTH_LONG,
  //             gravity: ToastGravity.BOTTOM,
  //             timeInSecForIosWeb: 2,
  //             backgroundColor: Colors.red,
  //             textColor: Colors.white,
  //             fontSize: 16.0);
  //       }
  //     });
  //   }
  // }

  Widget name() {
    return Positioned(
        child: Padding(
          padding: EdgeInsets.only(left: 21, top: 25),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            userAccount(context, userController.user,
                width: 46,
                height: 46,
                putActive: false,
                isProfile: true,
                showVerifiedIcon: false,
                navigateProfile: false, // no tap if already on profile
                color: Colors.white,
                walletName: true,
                messageIcon: false)
          ]),
        ),
        top: 0,
        left: 0);
  }

  Widget balance() {
    return Positioned(
        child: Padding(
          padding: EdgeInsets.only(left: 21, bottom: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Php 0.00',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                Text(
                  'Coming soon...',
                  style: TextStyle(color: Colors.white),
                )
              ]),
        ),
        bottom: 0,
        left: 0);
  }

  Widget addCredit() {
    return Positioned(
        child: GestureDetector(
            onTap: () {
              Get.snackbar('Coming Soon!', 'Coming Soon!');
            },
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                  color: Color(0XFFFECD4D),
                  // border: Border.all(
                  //   color: Color(0XFFFECD4D),
                  // ),
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(15))),
              child: Image.asset(
                'assets/images/add-creds.png',
                height: 20,
                width: 20,
                color: Colors.white,
              ),
            )),
        bottom: 0,
        right: 0);
  }

  Widget showWalletCards() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: false,
        height: 176,
        enableInfiniteScroll: false,
        //enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 4.0,
        //initialPage: 2,
        //onPageChanged: callbackFunction,
        //scrollDirection:Axis.vertical
      ),
      items: _wallets
          .map(
            (appointment) => GestureDetector(
                onTap: () {
                  // appointmentStatusModal(context, appointment);
                },
                child: Card(
                    color: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 10,
                    child: Container(
                      child: Stack(
                        children: [
                          name(),
                          balance(),
                          addCredit(),
                        ],
                      ),
                    ))),
          )
          .toList(),
    );
  }

  Widget showTransactionList() {
    return Container();
    // if (_appointments.length == 0) {
    //   return Padding(
    //       padding: EdgeInsets.only(left: 16), child: Text('No record yet'));
    // }
    // return Expanded(
    //     child: ListView.separated(
    //         itemCount: _appointments.length,
    //         separatorBuilder: (BuildContext context, int index) => Divider(),
    //         itemBuilder: (context, index) {
    //           return showHistory(_appointments[index]);
    //         }));
  }

  _navigatePaymentDetails(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCreditCard(
                selectedCardIndex: null,
                paymayaCustomerId: null,
              )),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success then reload the home page data
        print('card details' + result['selectedCard'].first6);

        // setState(() {
        //   _selectedCard = result['selectedCard'];
        //   _selectedCardIndex = result['selectedCardIndex'];

        //   if (_selectedCard!.cardType == 'master') {
        //     _cardType = 'MasterCard';
        //   }
        //   if (_selectedCard!.cardType == 'visa') {
        //     _cardType = 'Visa';
        //   }
        // });

        // Navigator.pop(context, {
        //   "payment_method": result['payment_method'],
        //   "result": "success",
        //   "selectedCard": _selectedCard,
        //   "selectedCardIndex": _selectedCardIndex,
        //   "cardType": _cardType
        // });
      }
    }
  }

  void callback() {
    // _navigatePaymentDetails(context);
    Get.snackbar('Coming Soon!', 'Coming Soon!');
  }

  Widget addCardButton() {
    return Padding(
        padding: EdgeInsets.only(left: 29, right: 29),
        child: iconActionButton(
            context: context,
            buttonColor: 'green',
            // icon: Icon(Icons.close),
            text: 'add card',
            // order: order,
            // orderCallback: rateOrder,
            isLoading: false,
            callback: callback));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: 'My Wallet'),
      backgroundColor: body_color,
      body: new SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: showWalletCards(),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Padding(
              //         padding: EdgeInsets.only(left: 29),
              //         child: Text('Transaction History',
              //             style: ThemeText.yellowLabel)),
              //     Padding(
              //         padding: EdgeInsets.only(right: 29),
              //         child: Text('Monthly')),
              //   ],
              // ),
              _isLoading ? spin() : showTransactionList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(child: addCardButton()),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: appBarTopWithBack(context, isMain: false, title: 'My Wallet'),
  //       // appBar: widget.noBackButton
  //       //     ? null
  //       //     : AppBar(
  //       //         backgroundColor: body_color,
  //       //         title: Text(
  //       //           'Online Wallet',
  //       //           style: TextStyle(color: Colors.black),
  //       //         ),
  //       //         elevation: 0,
  //       //         leading: popArrow(context),
  //       //         bottomOpacity: 0.0,
  //       //       ),
  //       backgroundColor: body_color,
  //       body: Center(
  //         child: Column(
  //           children: [
  //             Text('Wallet in Peso'),
  //             Consumer<ChangeNotifierPayment>(
  //               builder: (context, payment, child) {
  //                 if (payment.isFailed) {
  //                   // If failed
  //                   Fluttertoast.showToast(
  //                       msg: 'Payment failed! Please try again.',
  //                       toastLength: Toast.LENGTH_LONG,
  //                       gravity: ToastGravity.BOTTOM,
  //                       timeInSecForIosWeb: 2,
  //                       backgroundColor: Colors.red,
  //                       textColor: Colors.white,
  //                       fontSize: 16.0);
  //                   payment.setIsFailedFalse(); // set to false again
  //                 }
  //                 return payment.isAmountLoading
  //                     ? spin()
  //                     : Text(
  //                         payment.walletAmount!,
  //                         style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.bold),
  //                       );
  //               },
  //             ),
  //             new ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 //elevation: 5.0,
  //                 shape: new RoundedRectangleBorder(
  //                     borderRadius: new BorderRadius.circular(20.0),
  //                     side: BorderSide(color: Colors.green[700]!)),
  //                 primary: Colors.white,
  //               ),
  //               child: new Text('Cash In',
  //                   style: new TextStyle(fontSize: 12.0, color: Colors.black)),
  //               onPressed: () {
  //                 Navigator.of(context).push(MaterialPageRoute(
  //                     builder: (context) => TopUp(returnTo: widget.returnTo)));
  //               },
  //             )
  //           ],
  //         ),
  //       ));
  // }
}
