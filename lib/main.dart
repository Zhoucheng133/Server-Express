import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:server_express/lang/zh_tw.dart';
import 'package:server_express/main_window.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/general_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:server_express/getx/ssh_controller.dart';
import 'package:server_express/lang/en_us.dart';
import 'package:server_express/lang/zh_cn.dart';
import 'package:server_express/lang/ja_jp.dart';
import 'package:server_express/lang/ko_kr.dart';
import 'package:server_express/lang/de_de.dart';
import 'package:server_express/lang/ru_ru.dart';
import 'package:server_express/lang/es_es.dart';
import 'package:server_express/lang/pt_pt.dart';
import 'package:server_express/lang/fr_fr.dart';
import 'package:server_express/mobile/main_view.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(isDesktop()){
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: "Server Express",
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Get.put(SshController());
  Get.put(ServerController());
  final controller=Get.put(GeneralController());
  await controller.init();
  Get.put(FileController());

  runApp(const MainApp());
}

class MainTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'zh_CN': zhCN,
    'zh_TW': zhTW,
    'ja_JP': jaJP,
    'ko_KR': koKR,
    'de_DE': deDE,
    'ru_RU': ruRU,
    'es_ES': esES,
    'pt_PT': ptPT,
    'fr_FR': frFR,
  };
}

class MainApp extends StatefulWidget {


  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GeneralController controller=Get.find();

  @override
  Widget build(BuildContext context) {
    bool platformDarkMode=MediaQuery.of(context).platformBrightness==Brightness.dark;
    controller.darkModeHandler(platformDarkMode);

    return Obx(()=>
      GetMaterialApp(
        translations: MainTranslations(),
        locale: controller.lang.value.locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: supportedLocales.map((item)=>item.locale).toList(),
        fallbackLocale: supportedLocales[0].locale,
        theme: ThemeData(
          brightness: controller.darkMode.value ? Brightness.dark : Brightness.light,
          fontFamily: 'PuHui', 
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: controller.darkMode.value ? Brightness.dark : Brightness.light,
          ),
          textTheme: controller.darkMode.value ? ThemeData.dark().textTheme.apply(
            fontFamily: 'PuHui',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ) : ThemeData.light().textTheme.apply(
            fontFamily: 'PuHui',
          ),
        ),
        home: isDesktop() ? MainWindow() : MainView(),
      )
    );
  }
}
