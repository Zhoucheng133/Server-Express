import 'dart:io';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralController extends GetxController {
  Rx<Locale> lang=Rx(Locale("en", "US"));
  RxBool autoDark=true.obs;
  RxBool darkMode=false.obs;

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();

    String? languageCode=prefs.getString("languageCode");
    String? countryCode=prefs.getString("countryCode");

    if(languageCode==null || countryCode==null){
      final sysLang=Platform.localeName;
      languageCode = sysLang.split('_')[0];
      countryCode = sysLang.split('_').last;
      lang.value=Locale(languageCode, countryCode);
      Get.updateLocale(lang.value);
    }else{
      lang.value=Locale(languageCode, countryCode);
      Get.updateLocale(lang.value);
    }
  }

  GeneralController(){
    init();
  }
}