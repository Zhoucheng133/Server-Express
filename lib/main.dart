import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_express/desktop/main_window.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isWindows || Platform.isMacOS || Platform.isLinux){
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
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
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    final brightness = MediaQuery.of(context).platformBrightness; 

    return MaterialApp(
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
          seedColor: Colors.yellow,
          brightness: Brightness.dark,
        ),
      ) : ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        textTheme: GoogleFonts.notoSansScTextTheme(),
      ),
      home: Scaffold(
        body: MainWindow()
      ),
    );
  }
}
