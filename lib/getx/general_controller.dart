import 'dart:io';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageType{
  String name;
  Locale locale;

  LanguageType(this.name, this.locale);
}

List<LanguageType> get supportedLocales => [
  LanguageType("English", Locale("en", "US")),
  LanguageType("简体中文", Locale("zh", "CN")),
];

class GeneralController extends GetxController {
  Rx<LanguageType> lang=Rx(supportedLocales[0]);
  RxBool autoDark=true.obs;
  RxBool darkMode=false.obs;

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();

    int? langIndex=prefs.getInt("langIndex");

    if(langIndex==null){
      final sysLang=Platform.localeName;
      final languageCode = sysLang.split('_')[0];
      final countryCode = sysLang.split('_').last;
      final local=Locale(languageCode, countryCode);
      int index=supportedLocales.indexWhere((element) => element.locale==local);
      if(index==-1){
        prefs.setInt("langIndex", 0);
      }else{
        lang.value=supportedLocales[index];
        prefs.setInt("langIndex", index);
        lang.refresh();
      }
    }else{
      lang.value=supportedLocales[langIndex];
    }
    Get.updateLocale(lang.value.locale);
  }

  GeneralController(){
    init();
  }
}