import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:server_express/mobile/pages/download_view.dart';
import 'package:server_express/mobile/pages/file_view_m.dart';
import 'package:server_express/mobile/pages/home_view.dart';
import 'package:server_express/mobile/pages/settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  int curIndex=0;

  final ServerController serverController=Get.find();
  final FileController fileController=Get.find();

  Future<void> initDownload() async {
    String downloadDir=p.join((await getApplicationSupportDirectory()).path, "downloads");
    if (!await Directory(downloadDir).exists()) {
      await Directory(downloadDir).create(recursive: true);
    }
    fileController.downloadDir.value=downloadDir;
  }

  @override
  void initState() {
    super.initState();
    initDownload();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: serverController.nowServer.value==null ?  Scaffold(
          key: ValueKey(1),
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: "home".tr,
              ),
              NavigationDestination(
                icon: Icon(Icons.download_rounded),
                label: "download".tr,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: "settings".tr,
              )
            ],
            onDestinationSelected: (value){
              setState(() {
                curIndex=value;
              });
            },
            selectedIndex: curIndex,
          ),
          body: IndexedStack(
            key: ValueKey(1),
            index: curIndex,
            children: [
              HomeView(),
              DownloadView(),
              SettingsView(),
            ],
          ),
        ) : FileViewM(
          key: ValueKey(2),
        ),
      ),
    );
  }
}