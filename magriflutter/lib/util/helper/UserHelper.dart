import 'package:magri/util/helper/SharedPrefs.dart';

class UserHelper {

  static String getDrafts() {
    var drafts = SharedPrefs.getString('drafts');
    return drafts;
  }

}