final String columnId = 'id';
final String columnUserId = 'user_id';
final String columnSubject = 'subject';
final String columnText = 'text';
final String columnShortText = 'short_text';
final String columnRead = 'read';
final String columnAgo = 'ago';
final String columnRowColor = 'row_color';

class Notif {
  int? id;
  String? userId;
  String? subject;
  String? text;
  String? shortText;
  int? read;
  String? ago;
  String? rowColor;

  Notif(this.id, this.userId, this.subject, this.text, this.shortText, this.read, this.ago, this.rowColor);

  // Notif.map(dynamic obj) {
  //   this.id = obj['id'];
  //   this.name = obj['name'];
  //   this.cost = obj['cost'];
  //   this.price = obj['price'];
  //   this.qty = obj['qty'];
  // }

  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     columnName: name,
  //     columnCost: cost,
  //     columnPrice: price,
  //     columnQty: qty,
  //     columnVersion: version,
  //   };
  //   if (id != null) {
  //     map[columnId] = id;
  //     map[columnRemoteItemId] = remoteItemId;
  //   }
  //   return map;
  // }

  Notif.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    userId = map[columnUserId];
    text = map[columnText];
    shortText = map[columnShortText];
    read = map[columnRead];
    ago = map[columnAgo];
    rowColor = map[columnRowColor];
  }

  // From json
  Notif.fromJson(Map<String, dynamic> json)
      : id = json[columnId],
        userId = json[columnUserId],
        text = json[columnText],
        shortText = json[columnShortText],
        read = json[columnRead],
        ago = json[columnAgo],
        rowColor = json[columnRowColor];


  // Map<String, dynamic> toJson() =>
  // {
  //   columnId: id,
  //   columnName: name,
  //   columnCost: cost,
  //   columnPrice: price,
  //   columnQty: qty,
  //   columnVersion: version
  // };

}