import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:server_express/components/dialogs/about.dart';
import 'package:server_express/components/dialogs/language.dart';
import 'package:server_express/components/settings/setting_item.dart';
import 'package:server_express/getx/general_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  final GeneralController generalController = Get.find();

  String version="";

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = "v${packageInfo.version}";
    });
  }

  @override
  void initState() {
    super.initState();
    getVersion();
  }

  Future<void> showDarkModeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("darkMode".tr),
        content: Obx(
          ()=> Column(
            mainAxisSize: .min,
            children: [
              SettingItem(
              label: 'autoDark'.tr, 
              child: Transform.scale(
                scale: 0.8,
                child: Switch(
                  splashRadius: 0,
                  value: generalController.autoDark.value,
                  onChanged: (value){
                    generalController.changeAutoDark(value);
                  },
                ),
              ),
            ),
            SettingItem(
              enabled: !generalController.autoDark.value,
              label: 'darkMode'.tr, 
              child: Transform.scale(
                scale: 0.8,
                child: Switch(
                  splashRadius: 0,
                  value: generalController.darkMode.value,
                  onChanged: generalController.autoDark.value ? null : (value){
                    generalController.changeDarkMode(value);
                  },
                ),
              ),
            ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("ok".tr),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr),
        scrolledUnderElevation: 0.0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Obx(
        ()=> ListView(
          children: [
            ListTile(
              title: Text("lang".tr),
              subtitle: Text(generalController.lang.value.name),
              onTap: () => showLanguageDialog(context),
            ),
            ListTile(
              title: Text("darkMode".tr),
              subtitle: Text(generalController.autoDark.value ? "auto".tr : generalController.darkMode.value ? "on".tr : "off".tr),
              onTap: () => showDarkModeDialog(context),
            ),
            ListTile(
              title: Text("about".tr),
              subtitle: Text(version),
              onTap: ()=>showAbout(context),
            )
          ],
        ),
      )
    );
  }
}