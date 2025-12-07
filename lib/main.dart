import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_express/main_window.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/general_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:server_express/getx/ssh_controller.dart';
import 'package:server_express/lang/en_us.dart';
import 'package:server_express/lang/zh_cn.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isWindows || Platform.isMacOS || Platform.isLinux){
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
  Get.put(GeneralController());
  Get.put(FileController());

  runApp(const MainApp());
}

class MainTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'zh_CN': zhCN,
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
    final brightness = MediaQuery.of(context).platformBrightness;

    return Obx(()=>
      GetMaterialApp(
        translations: MainTranslations(),
        locale: controller.lang.value,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        theme: brightness==Brightness.dark ? ThemeData.dark().copyWith(
          textTheme: GoogleFonts.notoSansScTextTheme().apply(
            bodyColor: Colors.white,
            displayColor: Colors.white, 
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
        ) : ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          textTheme: GoogleFonts.notoSansScTextTheme(),
        ),
        home: MainWindow()
      )
    );
  }
}
