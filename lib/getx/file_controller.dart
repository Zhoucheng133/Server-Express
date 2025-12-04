import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/getx/ssh_controller.dart';
import 'package:path/path.dart' as p;

class FileClass{
  String name;
  bool isDir;
  int? size;
  bool selcted;
  FileClass({required this.name, required this.isDir, required this.size, this.selcted=false});

  factory FileClass.fromJson(Map<String, dynamic> json) {
    return FileClass(
      name: json['name'],
      isDir: json['type']=='dir',
      size: json['size'],
    );
  }

  Map toJson() => {
    'name': name,
    'isDir': isDir,
    'size': size,
    'selcted': selcted,
  };
}

class FileController extends GetxController {
  RxString path="/".obs;
  RxList<FileClass> files=<FileClass>[].obs;
  RxBool selectMode=false.obs;

  Future<void> getFiles(BuildContext context) async {
    final SshController sshController=Get.find();
    final String msg=await sshController.sftpList(path.value);
    try {
      final List<dynamic> list=jsonDecode(msg);
      files.value=list.map((item)=>FileClass.fromJson(item)).toList();
      files.sort((a, b){
        if (a.isDir && !b.isDir) {
          return -1;
        }
        if (!a.isDir && b.isDir) {
          return 1;
        }
        final String nameA = PinyinHelper.getPinyinE(a.name, separator: '').toLowerCase();
        final String nameB = PinyinHelper.getPinyinE(b.name, separator: '').toLowerCase();
        return nameA.compareTo(nameB);
      });
    } catch (_) {
      path.value="/";
      if(context.mounted){
        showGeneralOk(context, "noPath".tr, msg);
        getFiles(context);
      }
    }
  }

  Future<String> downloadFile(BuildContext context, String path, String local) async {
    String message=await Get.find<SshController>().sftpDownload(path, local);
    if(!message.contains("OK") && context.mounted){
      showGeneralOk(context, "cantDownload".tr, message);
      return message;
    }
    return message;
  }

  void deleteFile(BuildContext context, String path) async { 
    bool ok=await showGeneralConfirm(
      context, "deleteFileTitle".tr, 
      "${'delete'.tr}: ${p.basename(path)}\n${'deleteFileContent'.tr}", 
      okText: 'delete'.tr, 
    );
    if(ok){
      String message=await Get.find<SshController>().sftpDelete(path);
      if(!message.contains("OK") && context.mounted){
        showGeneralOk(context, "cantDelete".tr, message);
      }else if(context.mounted){
        getFiles(context);
      }
    }
  }

  void renameFile(BuildContext context, String path) async {
    final controller=TextEditingController(text: p.basename(path));
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text("rename".tr,),
        content: StatefulBuilder(
          builder: (context, setState)=>TextField(
            decoration: InputDecoration(
              labelText: "newName".tr,
            ),
            controller: controller,
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context),
            child: Text("cancel".tr),
          ),
          ElevatedButton(
            onPressed: () async {
              if(controller.text.isEmpty){
                showGeneralOk(context, "renameFail".tr, "renameEmpty".tr);
                return;
              }
              String message=await Get.find<SshController>().sftpRename(path, controller.text);
              if(context.mounted && !message.contains("OK")){
                showGeneralOk(context, "renameFail".tr, message);
              }else if(context.mounted){
                Navigator.pop(context);
                getFiles(context);
              }
            }, 
            child: Text('rename'.tr)
          )
        ],
      )
    );
  }

  Future<void> deletSelected(BuildContext context) async {
    int selectCount=files.where((element) => element.selcted).length;
    if(selectCount==0){
      showGeneralOk(context, "noSelect".tr, "noSelectContent".tr);
      return;
    }
    bool ok=await showGeneralConfirm(context, "deleteSelected".tr, "deleteSelectedContent".tr, okText: 'delete'.tr, );
    if(ok){
      for (var file in files) {
        if(file.selcted && context.mounted){
          String message=await Get.find<SshController>().sftpDelete(p.join(path.value, file.name));
          if(!message.contains("OK") && context.mounted){
            showGeneralOk(context, "cantDelete".tr, message);
          }
        }
      }
      if(context.mounted) getFiles(context);
      selectMode.value=false;
    }
  }

  RxString nowDownloadFile=RxString("");
  RxInt downloadCount=RxInt(0);
  RxInt downloadIndex=RxInt(0);

  void toggleSelectMode(){
    selectMode.value=!selectMode.value;
    for (var file in files) {
      file.selcted=false;
    }
    files.refresh();
  }

  void downloadSelected(BuildContext context) async {

    downloadCount.value=files.where((element) => element.selcted).length;
    if(downloadCount.value==0){
      showGeneralOk(context, "noSelect".tr, "noSelectContent".tr);
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null && context.mounted) {

      showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text("downloading".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 10,),
              Obx(()=>Text("${downloadIndex.value} / ${downloadCount.value}")),
              Obx(()=>Text("${'download'.tr}: ${nowDownloadFile.value}")),
            ]
          ),
        )
      );
      String message="";
      for (var file in files) {
        if(file.selcted){
          nowDownloadFile.value=file.name;
          message=await downloadFile(context, p.join(path.value, file.name), selectedDirectory);
          if(!message.contains("OK")){
            break;
          }
          downloadIndex.value++;
        }
      }
      if(context.mounted && message.contains("OK")){
        Navigator.pop(context);
      }else if(context.mounted){
        Navigator.pop(context);
        Navigator.pop(context);
        showGeneralOk(context, "cantDownload".tr, message);
      }

      selectMode.value=false;
      nowDownloadFile.value="";
      downloadCount.value=0;
      downloadIndex.value=0;
    }
  }
}