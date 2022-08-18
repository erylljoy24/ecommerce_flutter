final String columnId = 'id';
final String columnNumber = 'number';
final String columnTotalAmount = 'total_amount';
final String columnIsDefault = 'default';

class CreditCard {
  String? id;
  String? cardType;
  String? first6;
  String? last4;
  String? token;
  bool? isDefault = false;

  CreditCard(
      {this.id,
      this.cardType,
      this.first6,
      this.last4,
      this.token,
      this.isDefault = false});

  CreditCard.fromMap(Map<String, dynamic> map) {
    cardType = map['cardType'];
    if (cardType == 'master-card') {
      cardType = 'master';
    }
    first6 = map['first6'];
    last4 = map['last4'];
    token = map['cardTokenId'];
    isDefault = map['default'];
  }
}
