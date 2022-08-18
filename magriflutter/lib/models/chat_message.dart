import '../models/order_item.dart';
import '../models/product.dart';

final String columnId = 'id';
final String columnType = 'type';
final String columnTo = 'to';
final String columnFrom = 'from';
final String columnPosition = 'position';
final String columnMessage = 'messages';
final String columnOrderItem = 'order_item';
final String columnSent = 'sent';
final String columnSeen = 'seen';
final String columnCreatedAt = 'created_at';

const TYPE_TEXT = 'text';
const TYPE_IMAGE = 'image';
const TYPE_VOICE = 'voice';
const TYPE_SHOW_PAYMENT_METHOD = 'show_payment_method';
const TYPE_ORDER = 'order';
const TYPE_CONFIRM_ORDER = 'confirm_order';
const TYPE_CANCEL_ORDER = 'cancel_order';
const TYPE_REJECT_ORDER = 'reject_order';

class ChatMessage {
  String? id;
  String? type;
  String? to;
  String? from;
  String? position;
  String? messages;
  bool? sent;
  bool? seen;

  Product? product;
  OrderItem? orderItem;

  ChatMessage(this.id, this.type, this.to, this.from, this.messages);

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

  ChatMessage.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    type = map[columnType];
    to = map[columnTo];
    from = map[columnFrom];
    position = map[columnPosition];
    messages = map[columnMessage] ?? '';
    sent = map[columnSent] ?? false;
    seen = map[columnSeen] ?? false;

    if (map[columnOrderItem] != null) {
      orderItem = OrderItem.fromMap(map[columnOrderItem]);
    }

    // product = Product.fromMap(map[columnProduct]) ?? null;
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
