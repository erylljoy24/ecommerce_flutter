import '../models/user.dart';

final String columnId = 'id';
final String columnProductName = 'name';
final String columnImageURL = 'image_url';
final String columnQty = 'qty';
final String columnUnit = 'unit';
final String columnPrice = 'price';
final String columnDateTime = 'date_time';
final String columnTotal = 'total';

class ProductContribution {
  int? id;
  String? name;
  String? imageUrl;
  int? qty = 0;
  String? unit;
  String? price = '';
  String? total = '';
  String? dateTime = '';

  ProductContribution(
      {this.id,
      this.name,
      this.imageUrl,
      this.qty,
      this.unit,
      this.price,
      this.total,
      this.dateTime});

  ProductContribution.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    imageUrl = map[columnImageURL];
    qty = map[columnQty];
    unit = map[columnUnit];
    price = map[columnPrice];
    total = map[columnTotal];
    dateTime = map[columnDateTime];
  }
}
