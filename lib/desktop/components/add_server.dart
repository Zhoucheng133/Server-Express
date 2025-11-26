import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/add_server_content.dart';
import 'package:server_express/getx/server_controller.dart';

Future<void> addServer(BuildContext context) async {

  TextEditingController nameController=TextEditingController();
  TextEditingController addrController=TextEditingController();
  TextEditingController portController=TextEditingController(text: "22");
  TextEditingController usernameController=TextEditingController();
  TextEditingController passwordController=TextEditingController();

  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text('addServer'.tr),
      content: AddServerContent(
        nameController: nameController,
        addrController: addrController,
        portController: portController,
        usernameController: usernameController,
        passwordController: passwordController,
      ),
      actions: [
        TextButton(
          onPressed: ()=>Navigator.pop(context), 
          child: Text("cancel".tr),
        ),
        ElevatedButton(
          onPressed: () async {
            final ServerController serverController=Get.find();
            serverController.serverCheck(context, addrController.text, portController.text, usernameController.text, passwordController.text);
          },
          child: Text("add".tr)
        )
      ],
    )
  );
}