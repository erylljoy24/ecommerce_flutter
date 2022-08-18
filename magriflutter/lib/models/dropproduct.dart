import '../models/user.dart';

final String columnId = 'id';
final String columnProductName = 'name';
final String columnDescription = 'description';
final String columnUnit = 'unit';
final String columnPrice = 'price';
final String columnImageURL = 'image_url';
final String columnQuota = 'quota';
final String columnPercentage = 'percentage';
final String columnPercentageNumber = 'percentage_number';
final String columnQuotaText = 'quota_text';

class DropProduct {
  int? id;
  String? name;
  String? description;
  String? unit;
  String? price = '';
  String? imageUrl;
  int? quota;
  int? percentage;
  double? percentageNumber;
  String? quotaText;

  DropProduct(
      {this.id,
      this.name,
      this.description,
      this.unit,
      this.price,
      this.imageUrl,
      this.quota,
      this.percentage,
      this.percentageNumber});

  // DropProduct.map(dynamic obj) {
  //   this.id = obj[columnId];
  //   this.category = obj[columnCategory];
  //   this.name = obj[columnProductName];
  //   this.description = obj[columnDescription];
  //   this.imageUrl = obj[columnImageURL];
  //   this.ratings = obj[columnRatings];
  //   this.price = obj[columnPrice];
  //   this.stocks = obj[columnStocks];
  //   this.sold = obj[columnSold];
  //   this.user = obj[columnUser];
  // }

  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     columnId: id,
  //     columnCategory: category,
  //     columnName: name,
  //     columnImageURL: imageUrl,
  //     columnRatings: ratings,
  //     columnPrice: price,
  //     columnStocks: stocks,
  //     columnSold: sold,
  //   };

  //   return map;
  // }

  DropProduct.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    description = map[columnDescription];
    unit = map[columnUnit];
    price = map[columnPrice];
    imageUrl = map[columnImageURL];
    quota = map[columnQuota];
    percentage = map[columnQuota];
    percentageNumber = map[columnPercentageNumber];
    quotaText = map[columnQuotaText];
  }
}
