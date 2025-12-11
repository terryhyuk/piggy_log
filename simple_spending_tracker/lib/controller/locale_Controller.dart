import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

class Localecontroller extends GetxController{
  Rx<Locale> locale = const Locale('en','US').obs;

  changeLocale(String languageCode){
    if(languageCode == 'system'){
      locale.value = Get.deviceLocale ?? const Locale('en','US');
    }else{
      locale.value = Locale(languageCode);
    }
  Get.updateLocale(locale.value);
  }
}