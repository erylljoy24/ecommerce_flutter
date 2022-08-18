final String columnId = 'id';
final String columnUserName = 'user_name';
final String columnImageURL = 'image_url';
final String columnTags = 'tags';

class Participant {
  String? id;
  String? userName;
  String? imageUrl;
  String? tags;

  Participant(this.id, this.userName, this.imageUrl, this.tags);

  // Event.map(dynamic obj) {
  //   this.id = obj[columnId];
  //   this.name = obj[columnName];
  //   this.imageUrl = obj[columnImageURL];
  //   this.ratings = obj[columnRatings];
  //   this.price = obj[columnPrice];
  //   this.stocks = obj[columnStocks];
  //   this.sold = obj[columnSold];
  // }

  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     columnId: id,
  //     columnName: name,
  //     columnImageURL: imageUrl,
  //     columnRatings: ratings,
  //     columnPrice: price,
  //     columnStocks: stocks,
  //     columnSold: sold,
  //   };

  //   return map;
  // }

  Participant.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    userName = map[columnUserName];
    imageUrl = map[columnImageURL];
    tags = map[columnTags];
  }

  // // From json
  // Event.fromJson(Map<String, dynamic> json)
  //     : id = json[columnId],
  //       name = json[columnName],
  //       imageUrl = json[columnImageURL],
  //       ratings = json[columnRatings],
  //       stocks = json[columnStocks],
  //       sold = json[columnSold];

  // Map<String, dynamic> toJson() => {
  //       columnId: id,
  //       columnName: name,
  //       columnImageURL: imageUrl,
  //       columnRatings: ratings,
  //       columnPrice: price,
  //       columnStocks: stocks,
  //       columnSold: sold
  //     };
}
