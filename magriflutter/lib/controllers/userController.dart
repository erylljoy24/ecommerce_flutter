import 'package:get/get.dart';
import 'package:magri/models/category.dart';
import 'package:magri/models/user.dart';

class UserController extends GetxController {
  User? user;

  String userType = 'buyer';

  String name = '111';

  User? get currentUser => user;

  void setUser(User? u) {
    user = u;
    update();
  }

  void setName(String n) {
    // print('call controller');
    name = n;
    update();
  }

  bool isBuyer() {
    return user!.type == User.BUYER_TYPE;
  }

  bool isSeller() {
    return user!.type == User.SELLER_TYPE;
  }

  final categories = Rx<List<Category>>([]);

  Future fetchCat() async {
    await fetchCategories().then((cat) {
      categories.value = cat;
      update();
    });
  }
}
