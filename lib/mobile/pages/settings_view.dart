import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/language.dart';
import 'package:server_express/getx/general_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  final GeneralController generalController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr),
        scrolledUnderElevation: 0.0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView(
        children: [
          Obx(
            ()=> ListTile(
              title: Text("lang".tr),
              subtitle: Text(generalController.lang.value.name),
              onTap: () => showLanguageDialog(context),
            ),
          ),
          ListTile(
            title: Text("darkMode".tr),
            // trailing: Switch(
            //   value: generalController.darkMode.value,
            //   onChanged: (value) => generalController.darkMode.value = value,
            // ),
          )
        ],
      )
    );
  }
}