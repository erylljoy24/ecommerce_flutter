import 'package:get/get.dart';
import 'package:magri/models/user.dart';

class FilterController extends GetxController {
  User? user;

  final userType = ''.obs;
  User? get currentUser => user;

  // final count1 = 10.obs;
  // final count2 = 0.obs;
  // int get sum => count1.value + count2.value;

  // String? get getUserType => userType.value;
  final filterTitle = Rx<String>('Filter');

  final form = Rx<String>('default');

  var distanceLabel = Rx<String>('(All)');
  var priceLabel = Rx<String>('(All)');
  var rateLabel = Rx<String>('(All)');

  // String? get priceLabel =>
  //     priceMin.value.toString() + ' ' + priceMax.value.toString();

  final showDistance = Rx<bool>(false);
  final showPrice = Rx<bool>(false);
  final showRate = Rx<bool>(false);

  final distance = Rx<double>(0.0);

  final priceMin = Rx<double>(0.0);
  final priceMax = Rx<double>(0.0);

  final ratings = Rx<double>(0.0);

  void clearAll() {
    setDistance(0.0);
    setPrice(0.0, 0.0);
    setRate(0.0);
    distanceLabel.value = '(All)';
    priceLabel.value = '(All)';
    rateLabel.value = '(All)';

    update();
  }

  void setDistance(double d) {
    distance.value = d;
    distanceLabel.value = d.toString() + ' km.';
    update();
  }

  void setPriceMin(double pMin) {
    priceMin.value = pMin;
    priceLabel.value = 'Php ' + priceMin.string + ' - ' + priceMax.string;
  }

  void setPriceMax(double pMax) {
    priceMax.value = pMax;
    priceLabel.value = 'Php ' + priceMin.string + ' - ' + priceMax.string;
  }

  void setPrice(double pMin, double pMax) {
    priceMin.value = pMin;
    priceMax.value = pMax;
    priceLabel.value = 'Php ' + priceMin.string + ' - ' + priceMax.string;
  }

  void setRate(double r) {
    ratings.value = r;
    rateLabel.value = ratings.string + ' star(s)';
  }
}
