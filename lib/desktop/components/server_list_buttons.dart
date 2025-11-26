import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/desktop/components/dialogs/add_server.dart';
import 'package:server_express/desktop/components/header_button_item.dart';
import 'package:server_express/desktop/components/dialogs/settings.dart';

class ServerListButtons extends StatefulWidget {
  const ServerListButtons({super.key});

  @override
  State<ServerListButtons> createState() => _ServerListButtonsState();
}

class _ServerListButtonsState extends State<ServerListButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeaderButtonItem(buttonSide: ButtonSide.left, func: ()=>showAddServer(context), icon: Icons.add_rounded, text: "addServer".tr),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: ()=>showSettings(context), icon: Icons.settings_rounded, text: "settings".tr),
      ],
    );
  }
}