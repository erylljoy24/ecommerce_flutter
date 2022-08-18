final String columnId = 'id';
final String columnName = 'name';
final String columnBalance = 'balance';

class Wallet {
  String? id;
  String? name = '';
  double? balance = 0;

  Wallet({
    this.id,
    this.name,
    this.balance,
  });

  Wallet.map(dynamic obj) {
    this.id = obj[columnId];
    this.name = obj[columnName];
    this.balance = obj[columnBalance];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnId: id,
      columnName: name,
      columnBalance: balance,
    };

    return map;
  }

  Wallet.fromMap(Map<String, dynamic> map) {
    id = map[columnId].toString();
    name = map[columnName];
    balance = map[columnBalance];
  }
}
