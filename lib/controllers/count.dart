import 'package:get/get.dart';

class CountController extends GetxController {
  var count = 0.obs;
  var count2 = 0.obs;

  void increment() {
    count++;
  }

  void increment2() {
    count2++;
  }
}
