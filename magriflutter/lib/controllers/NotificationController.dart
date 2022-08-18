import 'package:get/get.dart';

class NotificationController extends GetxController {
  final countUnread = Rx<int>(0);

  void setUnread(int unread) {
    countUnread.value = unread;
    update();
  }

  void increment() {
    countUnread.value += 1;
    update();
  }

  void clearUnread() {
    countUnread.value = 0;
    update();
  }

  void storeToken(String token) async {
    Map<String, dynamic> payload = {
      "token": token,
    };
    // var data = await BaseClient().post('/addresses/', payload);

    // return data;
  }
}
