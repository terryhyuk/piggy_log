import 'package:get_x/get.dart';

class TabbarController extends GetxController{
  var index = 0.obs;
  void changeTabIndex(int newIndex) {
    index.value = newIndex;
  }
}