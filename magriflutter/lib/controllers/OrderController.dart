import 'package:get/get.dart';
import 'package:magri/models/order.dart';
import 'package:magri/models/user.dart';

class OrderController extends GetxController {
  bool isLoading = false;
  bool isLoaded = false;

  List<Order> orders = [];

  List<Order> pending = [];
  List<Order> confirmed = [];
  List<Order> delivered = [];
  List<Order> completed = [];
  List<Order> cancelled = [];

  List<Order>? get all => orders;

  String paymentMethod = 'cod';

  void setOrders(User? u) {
    update();
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    update();
  }

  void getOrders() async {
    isLoading = true;
    update();
    fetchOrders().then((dataItems) {
      if (dataItems != null) {
        pending.clear();
        confirmed.clear();
        delivered.clear();
        completed.clear();
        cancelled.clear();
        dataItems.forEach((item) {
          String stat = Order.fromMap(item).status!;
          if (stat == STATUS_NEW) {
            pending.add(Order.fromMap(item));
          }
          if (stat == STATUS_CONFIRMED) {
            confirmed.add(Order.fromMap(item));
          }
          if (stat == STATUS_TODELIVER) {
            delivered.add(Order.fromMap(item));
          }
          if (stat == STATUS_COMPLETED) {
            completed.add(Order.fromMap(item));
          }
          if (stat == STATUS_CANCELLED) {
            cancelled.add(Order.fromMap(item));
          }
          // update();
        });
      }
      isLoading = false;
      isLoaded = true;
      update();
    });
  }
}
