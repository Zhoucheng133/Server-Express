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
  LanguageType("繁體中文", Locale("zh", "TW")),
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
      final deviceLocale=PlatformDispatcher.instance.locale;
      final local=Locale(deviceLocale.languageCode, deviceLocale.countryCode);
      int index=supportedLocales.indexWhere((element) => element.locale==local);
      if(index!=-1){
        lang.value=supportedLocales[index];
        lang.refresh();
      }
    }else{
      lang.value=supportedLocales[langIndex];
    }

    autoDark.value=prefs.getBool("autoDark")??true;
    darkMode.value=prefs.getBool("darkMode")??false;
  }

  void changeLanguage(int index){
    lang.value=supportedLocales[index];
    prefs.setInt("langIndex", index);
    lang.refresh();
    Get.updateLocale(lang.value.locale);
  }

  void darkModeHandler(Brightness brightness){ 
    if(autoDark.value){
      darkMode.value=brightness==Brightness.dark;
    }
  }

  void changeAutoDark(bool auto){
    autoDark.value=auto;
    prefs.setBool("autoDark", auto);
  }

  void changeDarkMode(bool dark){
    darkMode.value=dark;
    prefs.setBool("darkMode", dark);
  }
}