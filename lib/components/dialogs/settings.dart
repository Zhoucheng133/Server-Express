import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/settings/settings_content.dart';

void showSettings(BuildContext context){
  showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text('settings'.tr),
      content: SizedBox(
        width: 250,
        child: SettingsContent(),
      ),
      actions: [
        ElevatedButton(
          onPressed: ()=>Navigator.pop(context), 
          child: Text("close".tr)
        )
      ],
    )
  );
}