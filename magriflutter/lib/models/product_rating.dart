import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';

final String columnId = 'id';
final String columnOrderId = 'order_id';
final String columnUserId = 'user_id';
final String columnUser = 'user';
final String columnRating = 'rating';
final String columnRatingMessage = 'rating_message';
final String columnDateFormat = 'date_format';

class ProductRating {
  // String id;
  int productId = 0;
  int? orderId;
  int userId = 0;
  User? user;
  double? rating;
  String? ratingMessage;
  String? dateFormat;

  ProductRating(this.orderId);

  ProductRating.fromMap(Map<String, dynamic> map) {
    // id = map[columnId].toString();
    orderId = map[columnOrderId];
    userId = map[columnUserId];
    if (map[columnUser] != null) {
      user = User.fromMap(map[columnUser]);
    }

    rating = intToDouble(map[columnRating]);
    ratingMessage = map[columnRatingMessage] ?? '';
    dateFormat = map[columnDateFormat];
  }
}
