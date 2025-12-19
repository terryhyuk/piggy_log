import 'package:get_x/get.dart';

class TabbarController extends GetxController{
  var index = 0.obs;
  var isCategoryEditMode = false.obs;

  void changeTabIndex(int newIndex) {
    if (index.value == 1) {  
      isCategoryEditMode.value = false;
    }
    index.value = newIndex;
  }
}