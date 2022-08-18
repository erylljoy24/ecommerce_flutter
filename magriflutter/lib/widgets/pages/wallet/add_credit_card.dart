import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/models/changenotifiers/change_notifier_payment.dart';
import 'package:magri/models/credit_card.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/services/paymaya.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/paymaya_view.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/colors.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCreditCard extends StatefulWidget {
  final Product? product;
  final int? selectedCardIndex;
  final String? paymayaCustomerId;
  AddCreditCard({this.product, this.selectedCardIndex, this.paymayaCustomerId});
  @override
  State<StatefulWidget> createState() => new _AddCreditCardState();
}

class _AddCreditCardState extends State<AddCreditCard> {
  bool isLoading = false;

  bool _addCardButtonLoading = false;

  String cardNumber = '4123450131001381'; // For testing
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  bool _showCreateForm = false;
  bool _showConfirmSelection = false;

  int _selectedCardIndex = 0;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Auth auth = new Auth();

  Paymaya paymaya = new Paymaya();

  String? _paymayaCustomerId;

  @override
  void initState() {
    super.initState();

    currentFile('add_credit_card.dart');

    checkAuth();

    if (widget.paymayaCustomerId != null) {
      setState(() {
        _paymayaCustomerId = widget.paymayaCustomerId;
      });
    }

    if (widget.selectedCardIndex != null) {
      setState(() {
        _showConfirmSelection = true;
      });
    }
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

        // Call paymaya api again for new list
        if (_paymayaCustomerId != null) {
          getCustomerCards(_paymayaCustomerId!);
        }
      });
    });
  }

  void getCustomerCards(String customerId) async {
    paymaya.getCustomerCards(customerId: customerId).then((dataItems) {
      print(dataItems.toString() + "dataItems");
      if (!mounted) {
        return;
      }

      // 4123 4501 3100 0508

      // print(dataItems.toString());
      setState(() {
        if (dataItems != null) {
          Provider.of<ChangeNotifierPayment>(context, listen: false)
              .clearVaultedCreditCards();
          dataItems.forEach((item) {
            Provider.of<ChangeNotifierPayment>(context, listen: false)
                .addSelectedCard(CreditCard.fromMap(item).isDefault);
            Provider.of<ChangeNotifierPayment>(context, listen: false)
                .addCard(CreditCard.fromMap(item));
          });
        }
      });
    });
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

  void addCard() {
    setState(() {
      _addCardButtonLoading = true;
    });
    if (formKey.currentState!.validate()) {
      print('valid!');
      _navigateStoreCard(context, cardNumber);
    } else {
      print('invalid!');
    }

    setState(() {
      _addCardButtonLoading = false;
    });
  }

  _navigateStoreCard(BuildContext context, String number) async {
    // If no exiting _paymayaCustomerId then we create one
    if (_paymayaCustomerId == null) {
      var customerData = await paymaya.createCustomer(customer: {
        "firstName": "Name",
      });

      print('customer id: ' + customerData['id']);

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
        print('add card success');

        setState(() {
          _showCreateForm = false;
        });

        checkAuth();
        // Call paymaya api again for new list
        if (_paymayaCustomerId != null) {
          getCustomerCards(_paymayaCustomerId!);
        }
        print(result.toString());
      }
    } else {
      print('cancelled');
    }
  }

  void confirmSelection() {
    print('confirmSelection...');

    CreditCard _selectedCard =
        Provider.of<ChangeNotifierPayment>(context, listen: false)
            .getVaultedCreditCards()[_selectedCardIndex];

    // Make sure that csv is not blank
    Navigator.pop(context, {
      "payment_method": "card",
      "result": "success",
      "selectedCard": _selectedCard,
      "selectedCardIndex": _selectedCardIndex
    });
  }

  Widget confirmSelectionButton() {
    return Consumer<ChangeNotifierPayment>(
      builder: (context, payment, child) {
        if (payment.vaultedCreditCards.isEmpty) {
          return Text('');
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SafeArea(
                child: Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16),
              child: iconActionButton(
                  context: context,
                  buttonColor: 'green',
                  text: 'Confirm selection',
                  callback: confirmSelection),
            )),
          ],
        );
      },
    );
  }

  Widget vaultedCards() {
    return Consumer<ChangeNotifierPayment>(
      builder: (context, payment, child) {
        if (payment.vaultedCreditCards.isEmpty) {
          return Container();
        }
        return Container(
          padding: EdgeInsets.only(top: 10),
          height: (100 * payment.vaultedCreditCards.length).toDouble(),
          child: ListView.separated(
            itemCount: payment.vaultedCreditCards.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return vaultCard(index, payment: payment);
            },
          ),
        );
      },
    );
  }

  Widget vaultCard(int index, {required ChangeNotifierPayment payment}) {
    return GestureDetector(
        onTap: () {
          //
          print('tap card');
          setState(() {
            payment.setSelectedCard(index);

            print('ok');

            // Count cards then make them all false
            // _selectedCard[index] = true;
            _selectedCardIndex = index;
            _showConfirmSelection = true;
            _showCreateForm = false;
          });
        },
        child: Container(
          height: 70,
          // margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(
                  color: payment.getSelectedCards()[index]!
                      ? Colors.green
                      : Colors.transparent)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(payment.getSelectedCards()[index].toString()),
              Row(
                children: [
                  SizedBox(
                      width: 44,
                      child: SvgPicture.asset(
                        'assets/images/wallet/' +
                            payment.vaultedCreditCards[index].cardType! +
                            '.svg',
                        height: 18,
                        width: 44,
                        // color: Colors.green,
                      )),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(payment.vaultedCreditCards[index].first6! +
                          ' ****** ' +
                          payment.vaultedCreditCards[index].last4!),
                      Text('Credit/Debit card'),
                      // _selectedCard[index]
                      //     ? SizedBox(
                      //         height: 30,
                      //         width: 100,
                      //         child: TextFormField(
                      //           keyboardType: TextInputType.number,
                      //           autofocus: false,
                      //           decoration: new InputDecoration(
                      //             filled: true,
                      //             fillColor: Colors.grey[100],
                      //             labelStyle:
                      //                 new TextStyle(color: Colors.black),
                      //             enabledBorder: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(2.0),
                      //               borderSide: BorderSide(
                      //                 color: inputBorderColor,
                      //                 //width: 2.0,
                      //               ),
                      //             ),
                      //             focusedBorder: UnderlineInputBorder(
                      //               borderSide:
                      //                   BorderSide(color: Colors.grey[100]),
                      //             ),
                      //           ),
                      //         ))
                      //     : Text(''),
                    ],
                  )
                ],
              ),
              payment.getSelectedCards()[index]!
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      //backgroundImage: CachedNetworkImageProvider(seller.image),
                      radius: 10,
                    )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context,
          isMain: false, title: 'Add Credit/Debit Card'),
      backgroundColor: body_color,
      body: new Container(
        padding: EdgeInsets.fromLTRB(27, 16, 27, 16),
        child: ListView(children: [
          // CreditCardWidget(
          //   cardNumber: cardNumber,
          //   expiryDate: expiryDate,
          //   cardHolderName: cardHolderName,
          //   cvvCode: cvvCode,
          //   showBackView: isCvvFocused,
          //   obscureCardNumber: true,
          //   obscureCardCvv: true,
          // ),
          vaultedCards(),
          Container(
              height: 60,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.green)),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCreateForm = !_showCreateForm;
                    _showConfirmSelection = false;
                  });
                },
                child: Center(child: Text('Add New Card')),
              )),
          _showCreateForm
              ? Container(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text('Credit Card Details',
                            style: ThemeText.yellowLabel)),
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: false,
                      cardNumber: cardNumber,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      expiryDate: expiryDate,
                      themeColor: Colors.grey,
                      cardNumberDecoration: const InputDecoration(
                        filled: true,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        hintStyle: TextStyle(color: hintTextColor),
                      ),
                      // numberValidationMessage: 'Car Number is required',
                      expiryDateDecoration: const InputDecoration(
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        filled: true,
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        hintStyle: TextStyle(color: hintTextColor),
                      ),
                      // dateValidationMessage: 'Expiry Date is required',
                      cvvCodeDecoration: const InputDecoration(
                        filled: true,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        labelText: 'CVV',
                        hintText: 'XXX',
                        hintStyle: TextStyle(color: hintTextColor),
                      ),
                      cvvValidationMessage: 'CVV is required',
                      cardHolderDecoration: const InputDecoration(
                        filled: true,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        labelText: 'Name on Card',
                        hintStyle: TextStyle(color: hintTextColor),
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'I acknowledge that by saving my card, OTP will not be required for transactions.',
                      style: TextStyle(color: sentenceTextColor),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'We ensure that your credit card details are kept safe and secure. Magri will not have access to your credit card info.',
                      style: TextStyle(color: sentenceTextColor),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    _addCardButtonLoading
                        ? spin()
                        : iconActionButton(
                            context: context,
                            buttonColor: 'green',
                            text: 'add card',
                            callback: addCard),
                  ],
                ))
              : Text(''),
        ]),
      ),
      bottomNavigationBar: !_showConfirmSelection
          ? null
          : SafeArea(child: confirmSelectionButton()),
    );
  }
}
