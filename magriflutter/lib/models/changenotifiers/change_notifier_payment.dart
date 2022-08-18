import 'package:flutter/foundation.dart';
import 'package:magri/models/credit_card.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/services/paymaya.dart';
import 'package:magri/util/helper.dart';

import '../order.dart';

class ChangeNotifierPayment with ChangeNotifier, DiagnosticableTreeMixin {
  Auth auth = new Auth();
  Paymaya paymaya = new Paymaya();

  Order? _order;

  bool _isAmountLoading = false;
  bool _isFailed = false;

  String _returnTo = ''; //  returnTo page after payment
  String? _walletAmount = '0.00';

  bool get isAmountLoading => _isAmountLoading;
  bool get isFailed => _isFailed;

  String? get walletAmount => _walletAmount;

  String get returnTo => _returnTo;

  List<CreditCard> _creditCards = [];

  List<bool?> _selectedCreditCards = [];

  int? _selectedCardIndex;

  int? get selectedCardIndex => _selectedCardIndex;

  List<bool?> get selectedCreditCards => _selectedCreditCards;

  List<CreditCard> get vaultedCreditCards => _creditCards;

  void clearVaultedCreditCards() {
    _creditCards.clear();
    _selectedCreditCards.clear();
    notifyListeners();
  }

  void addCard(CreditCard card) {
    _creditCards.add(card);
    notifyListeners();
  }

  void addSelectedCard(bool? isSelected) {
    _selectedCreditCards.add(isSelected);
    notifyListeners();
  }

  List<bool?> getSelectedCards() {
    return _selectedCreditCards;
  }

  List<CreditCard> getVaultedCreditCards() {
    return _creditCards;
  }

  void setSelectedCard(int index) {
    var i = 0;
    for (final selected in _selectedCreditCards) {
      _selectedCreditCards[i] = false;
      i++;
    }
    _selectedCreditCards[index] = true;
    _selectedCardIndex = index;

    notifyListeners();
  }

  // void getCards(String customerId) async {
  //   paymaya.getCustomerCards(customerId: customerId).then((dataItems) {
  //     print(dataItems.toString());
  //     if (dataItems != null) {
  //       _creditCards.clear();
  //       dataItems.forEach((item) {
  //         _creditCards.add(CreditCard.fromMap(item));
  //       });
  //     }
  //   });

  //   notifyListeners();
  // }

  void setOrder(Order order) {
    _order = order;
    notifyListeners();
  }

  void setReturnTo(String returnTo) {
    _returnTo = returnTo;
    notifyListeners();
  }

  void setIsFailedFalse() {
    _isFailed = false;
    notifyListeners();
  }

  // Get auth so that we can get if user have paymaya customer id already
  void checkAuth(String? checkoutId) async {
    _isAmountLoading = true;
    notifyListeners();
    auth.signInToken().then((value) {
      print('auth ok');

      auth.getUserData().then((userData) {
        _walletAmount = userData['wallet_amount'];
        notifyListeners();
        _isAmountLoading = false;
        notifyListeners();

        checkStatus(checkoutId);
      });
    });
    print('auth');
  }

  //  4123 4501 3100 1381
  void checkStatus(String? checkoutId) async {
    if (checkoutId != null) {
      _isAmountLoading = true;
      notifyListeners();
      paymaya.getStatus(checkoutId).then((paymentData) {
        print('Wallet: =====' + paymentData.toString());
        print('=====' + paymentData['id']);
        print('=====' + paymentData['status']);
        print('=====' + paymentData['amount']);
        if (paymentData['status'] == 'PAYMENT_SUCCESS') {
          var existingAmount = double.parse(_walletAmount!);
          var successAmount = double.parse(paymentData['amount']);
          var totalAmount = existingAmount + successAmount;

          // Push the new amount to server
          storeNewAmount(paymentData['id'], checkoutId, paymentData['amount'])
              .then((success) {
            if (success) {
              _walletAmount = totalAmount.toString();
              notifyListeners();
            }
            _isAmountLoading = false;
            notifyListeners();
          });
        } else {
          _isFailed = true;
          _isAmountLoading = false;
          notifyListeners();
        }
      });
    }
  }
}
