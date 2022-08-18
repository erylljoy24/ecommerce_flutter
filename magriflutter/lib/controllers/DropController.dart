import 'package:get/get.dart';
import 'package:magri/models/drop.dart';

class DropController extends GetxController {
  final isLoading = Rx<bool>(false);
  final items = Rx<List<Drop>>([]);

  void addItem(Drop item) {
    items.value.add(item);
    update();
  }

  void setItems(List<Drop> drops) {
    items.value = drops;
    update();
  }

  void getItems() async {
    isLoading.value = true;
    await fetchDrops().then((dropItems) {
      setItems(dropItems);

      print('setItems');
      isLoading.value = false;
    });
    update();
  }
}
