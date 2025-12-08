import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/getx/general_controller.dart';

void showLanguageDialog(BuildContext context){

  final GeneralController generalController=Get.find();

  showDialog(
    context: context, 
    builder: (context)=> AlertDialog( 
      title: Text('lang'.tr),
      content: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          value: generalController.lang.value.name,
          items: supportedLocales.map((item)=>DropdownMenuItem<String>(
            value: item.name,
            child: Text(
              item.name
            ),
          )).toList(),
          onChanged: (val){
            final index=supportedLocales.indexWhere((element) => element.name==val);
            generalController.changeLanguage(index);
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text('ok'.tr),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}