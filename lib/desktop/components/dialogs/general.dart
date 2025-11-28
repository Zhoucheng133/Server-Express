import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showGeneralConfirm(BuildContext context, String title, String content, {String okText="ok", String cancelText="cancel"}) async {
  bool ok=false;
  await showDialog(
    context: context, 
    builder: (context)=>StatefulBuilder(
      builder: (context, setState)=>AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: Text(cancelText.tr)
          ),
          ElevatedButton(
            onPressed: (){
              setState((){
                ok=true;
              });
              Navigator.pop(context);
            }, 
            child: Text(okText.tr)
          )
        ],
      )
    )
  );
  return ok;
}