import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/language.dart';
import 'package:server_express/components/settings/setting_item.dart';
import 'package:server_express/getx/general_controller.dart';

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {

  final GeneralController generalController=Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingItem(
            label: 'autoDark'.tr, 
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                splashRadius: 0,
                value: generalController.autoDark.value,
                onChanged: (value){
                  generalController.autoDark.value=value;
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
                  generalController.darkMode.value=value;
                },
              ),
            ),
          ),
          SettingItem(
            label: 'lang'.tr, 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.earthAsia,
                  size: 14,
                ),
                const SizedBox(width: 5,),
                Text(generalController.lang.value.name),
                TextButton(
                  onPressed: (){
                    showLanguageDialog(context);
                  }, 
                  child: Text('change'.tr)
                )
              ]
            )
          )
        ],
      ),
    );
  }
}