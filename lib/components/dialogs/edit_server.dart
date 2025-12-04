import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/add_server/add_server_content.dart';
import 'package:server_express/getx/server_controller.dart';

Future<void> showEditServer(BuildContext context, Server server) async {
  TextEditingController nameController=TextEditingController(text: server.name);
  TextEditingController addrController=TextEditingController(text: server.addr);
  TextEditingController portController=TextEditingController(text: server.port);
  TextEditingController usernameController=TextEditingController(text: server.username);
  TextEditingController passwordController=TextEditingController(text: server.password);

  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text('editServer'.tr),
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
            serverController.editServer(
              context,
              Server(
                id: server.id, 
                name: nameController.text, 
                addr: addrController.text, 
                port: portController.text, 
                username: usernameController.text, 
                password: passwordController.text,
              )
            );
          },
          child: Text("save".tr)
        )
      ],
    )
  );
}