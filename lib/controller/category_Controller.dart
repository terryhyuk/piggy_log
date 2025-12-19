import 'package:get_x/get.dart';

class CategoryController extends GetxController{
  RxInt refreshTrigger = 0.obs;

  void notifyChange() {
    refreshTrigger++;
  }
}