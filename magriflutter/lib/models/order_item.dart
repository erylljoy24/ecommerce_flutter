import 'package:magri/util/helper.dart';

import '../models/product.dart';

final String columnId = 'id';
final String columnOrderId = 'order_id';
final String columnOrderNumber = 'number';
final String columnProductId = 'product_id';
final String columnProductName = 'product_name';
final String columnProductDescription = 'description';
final String columnProductUnit = 'unit';
final String columnProductPrice = 'price';
final String columnProduct = 'product';
final String columnQuantity = 'quantity';
final String columnTotal = 'total';
final String columnPaymentMethod = 'payment_method';
final String columnStatus = 'status';

class OrderItem {
  String? id;
  int? orderId;
  String? orderNumber;
  int? productId;
  String? productName;
  String? productDescription;
  String? productUnit;
  double? productPrice;
  int? quantity;
  double? price;
  String? total;
  String? paymentMethod;
  late String status;

  Product? product;

  OrderItem(this.id, this.orderId, this.product, this.quantity, this.total);

  // Order.map(dynamic obj) {
  //   this.id = obj[columnId];
  //   this.category = obj[columnCategory];
  // }

  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     columnId: id,
  //     columnCategory: category,
  //   };

  //   return map;
  // }

  OrderItem.fromMap(Map<String, dynamic> map) {
    id = map[columnId].toString();
    orderId = map[columnOrderId] ?? '' as int?;
    //orderNumber = map[columnOrderNumber] ?? '';
    productId = map[columnProductId];
    productName = map[columnProductName];
    productDescription = map[columnProductDescription];
    productUnit = map[columnProductUnit];
    productPrice = intToDouble(map[columnProductPrice]);
    if (map[columnProduct] != null) {
      product = Product.fromMap(map[columnProduct]);
    }

    quantity = map[columnQuantity];
    total = map[columnTotal];
    paymentMethod = map[columnPaymentMethod] ?? '';
    status = map[columnStatus] ?? '';
  }

  // // From json
  // Order.fromJson(Map<String, dynamic> json)
  //     : id = json[columnId],
  //       name = json[columnName],
  //       category = json[columnCategory],
  //       sold = json[columnSold];

  // Map<String, dynamic> toJson() => {
  //       columnId: id,
  //       columnCategory: category,
  //       columnSold: sold
  //     };
}
