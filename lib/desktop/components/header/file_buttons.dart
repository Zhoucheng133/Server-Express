import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/desktop/components/dialogs/general.dart';
import 'package:server_express/desktop/components/header/header_button_item.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:server_express/getx/ssh_controller.dart';
import 'package:path/path.dart' as p;

class FileButtons extends StatefulWidget {
  const FileButtons({super.key});

  @override
  State<FileButtons> createState() => _FileButtonsState();
}

class _FileButtonsState extends State<FileButtons> {

  final SshController sshController=Get.find();
  final ServerController serverController=Get.find();
  final FileController fileController=Get.find();

  void disconnectServer(BuildContext context) async {
    bool ok=await showGeneralConfirm(context, "disconnect".tr, "disconnectContent".tr);
    if(ok){
      await sshController.disconnect();
      serverController.nowServer.value=null;
    }
  }

  void refreshFiles(BuildContext context) async {
    await fileController.getFiles(context);
  }

  void parentFolder(BuildContext context) async {
    if(fileController.path.value=="/"){
      return;
    }
    fileController.path.value=p.dirname(fileController.path.value);
    await fileController.getFiles(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeaderButtonItem(buttonSide: ButtonSide.left, func: ()=>disconnectServer(context), icon: Icons.link_off_rounded, text: "disconnect".tr),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>parentFolder(context), icon: Icons.keyboard_arrow_up_rounded, text: "parentFolder".tr),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>{}, icon: Icons.check_box_rounded, text: "select".tr),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: ()=>refreshFiles(context), icon: Icons.refresh_rounded, text: "refresh".tr),
      ],
    );
  }
}