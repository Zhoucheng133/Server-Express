import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/desktop/components/dialogs/add_server.dart';
import 'package:server_express/desktop/components/header/header_button_item.dart';
import 'package:server_express/desktop/components/dialogs/settings.dart';
import 'package:server_express/getx/ssh_controller.dart';

class ServerButtons extends StatefulWidget {
  const ServerButtons({super.key});

  @override
  State<ServerButtons> createState() => _ServerButtonsState();
}

class _ServerButtonsState extends State<ServerButtons> {

  final SshController sshController=Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeaderButtonItem(buttonSide: ButtonSide.left, func: ()=>showAddServer(context), icon: Icons.add_rounded, text: "addServer".tr),
        // 测试按钮
        HeaderButtonItem(buttonSide: ButtonSide.mid,  func: ()=>sshController.disconnect(), icon: Icons.link_off_rounded, text: "断开连接",),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: ()=>showSettings(context), icon: Icons.settings_rounded, text: "settings".tr),
      ],
    );
  }
}