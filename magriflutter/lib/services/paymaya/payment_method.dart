final String paymentMethodMagriWallet = 'magri-wallet';
final String paymentMethodCard = 'card';
final String paymentMethodCOD = 'cod';
final String paymentMethodEWallet = 'ewallet';
final String paymentMethodOverTheCounter = 'over-the-counter';
final String paymentMethodOnlineBank = 'online-bank';

class PaymentMethod {
  String? first6;
  String? last4;
  String? cardTokenId;
  String? cardType;
  String? maskedPan;
  String? walletType;
  String? state;
  String? isDefault;

  PaymentMethod({this.first6});

  PaymentMethod.fromMap(Map<String, dynamic> map) {
    first6 = map['first6'];
    last4 = map['last4'];
    cardTokenId = map['cardTokenId'];
    cardType = map['cardType'];
    maskedPan = map['maskedPan'];
    walletType = map['walletType'];
    state = map['state'];
    isDefault = map['default'];
  }
}

// {
//         "first6": "412345",
//         "last4": "1381",
//         "cardTokenId": "GWovJo7zWytrfiSCI6uILRr6hypif1YVgghJzCCXrPRfhTbtE5fOYXijTZc4YuHAGrPAVTdJdw1YaH31McIcwnMEph4V8m9DTOcxfGY43ME1PAJV4l1hfUPTqZKzERsN2GpSV9k9tA454SEdbcwTAdShUq4LSULKJdlTA",
//         "cardType": "visa",
//         "maskedPan": "1381",
//         "createdAt": "2021-04-16T12:37:14.000Z",
//         "updatedAt": "2021-04-16T12:37:14.000Z",
//         "walletType": "VAULTED",
//         "state": "VERIFIED",
//         "default": true
//     }
