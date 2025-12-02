import 'package:file_picker/file_picker.dart';
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

  // 上传相关
  RxString progressFileName=RxString("");
  RxBool isUploadingCancelled = false.obs;

  void disconnectServer(BuildContext context) async {
    bool ok=await showGeneralConfirm(context, "disconnect".tr, "disconnectContent".tr);
    if(ok){
      await sshController.disconnect();
      serverController.nowServer.value=null;
      fileController.path.value="/";
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

  Future<void> uploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      List paths = result.paths;

      if(context.mounted){
        showDialog(
          context: context, 
          builder: (context)=>AlertDialog(
            title: Text("uploading".tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 10,),
                Obx(()=>
                  Text("${'upload'.tr}: ${progressFileName.value}")
                )
              ]
            ),
            actions: [
              TextButton(
                onPressed: (){
                  isUploadingCancelled.value=true;
                }, 
                child: Text("cancel".tr)
              )
            ]

          )
        );
      }

      for(String path in paths){
        if (isUploadingCancelled.value) {
          break;
        }
        progressFileName.value=p.basename(path);
        String msg=await sshController.sftpUpload(p.join(fileController.path.value, p.basename(path)), path);
        if(context.mounted && msg.contains("OK")){
          await fileController.getFiles(context);
        }else if(context.mounted){
          showGeneralOk(context, "uploadFail".tr, msg);
        }
      }

      if(context.mounted) Navigator.pop(context);
      isUploadingCancelled.value = false;
      progressFileName.value = "";
    }
  }

  void uploadDir(BuildContext context) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      if(context.mounted){
        showDialog(
          context: context, 
          builder: (context)=>AlertDialog(
            title: Text("uploading".tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 10,),
                Obx(()=>
                  Text("${'upload'.tr}: ${progressFileName.value}")
                )
              ]
            ),
          )
        );
      }
      progressFileName.value=p.basename(selectedDirectory);
      String msg=await sshController.sftpUpload(p.join(fileController.path.value, p.basename(selectedDirectory)), selectedDirectory);
      if(context.mounted && msg.contains("OK")){
        await fileController.getFiles(context);
      }else if(context.mounted){
        showGeneralOk(context, "uploadFail".tr, msg);
      }
      if(context.mounted) Navigator.pop(context);
      progressFileName.value = "";
    }
  }

  Future<void> upload(BuildContext context) async {
    final rootContext = context;
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        contentPadding: EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: Text('uploadFile'.tr),
              onTap: (){
                Navigator.pop(context);
                uploadFile(rootContext);
              }
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: Text('uploadDir'.tr),
              onTap: (){
                Navigator.pop(context);
                uploadDir(rootContext);
              },
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeaderButtonItem(buttonSide: ButtonSide.left, func: ()=>disconnectServer(context), icon: Icons.link_off_rounded, text: "disconnect".tr),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>upload(context), icon: Icons.upload_file_rounded, text: "upload".tr),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>parentFolder(context), icon: Icons.keyboard_arrow_up_rounded, text: "parentFolder".tr),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>{}, icon: Icons.check_box_rounded, text: "select".tr),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: ()=>refreshFiles(context), icon: Icons.refresh_rounded, text: "refresh".tr),
      ],
    );
  }
}