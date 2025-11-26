import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSettings(BuildContext context){
  showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text('settings'.tr),
      actions: [
        ElevatedButton(
          onPressed: ()=>Navigator.pop(context), 
          child: Text("ok".tr)
        )
      ],
    )
  );
}