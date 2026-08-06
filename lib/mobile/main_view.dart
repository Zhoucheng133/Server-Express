import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/mobile/pages/download_view.dart';
import 'package:server_express/mobile/pages/home_view.dart';
import 'package:server_express/mobile/pages/settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  int curIndex=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        index: curIndex,
        children: [
          HomeView(),
          DownloadView(),
          SettingsView(),
        ],
      ),
    );
  }
}