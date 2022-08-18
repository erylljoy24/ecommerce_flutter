import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';

final String columnId = 'id';
final String columnSellerId = 'seller_id';
final String columnUserId = 'user_id';
final String columnUser = 'user';
final String columnRating = 'rating';
final String columnRatingMessage = 'rating_message';
final String columnDateFormat = 'date_format';

class UserRating {
  // String id;
  int? sellerId;
  int userId = 0;
  User? user;
  double? rating;
  String? ratingMessage;
  String? dateFormat;

  UserRating(this.sellerId);

  UserRating.fromMap(Map<String, dynamic> map) {
    // id = map[columnId].toString();
    sellerId = map[columnSellerId];
    userId = map[columnUserId];
    // print(map[columnUser] + '111====');
    if (map[columnUser] != null) {
      // print('user' + map[columnUser]);
      user = User.fromMap(map[columnUser]);
    }

    rating = intToDouble(map[columnRating]);
    ratingMessage = map[columnRatingMessage];
    if (ratingMessage == null) {
      ratingMessage = '';
    }
    dateFormat = map[columnDateFormat];
  }
}
