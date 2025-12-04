import 'dart:convert';

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

  void downloadFile(BuildContext context, String path, String local) async {
    String message=await Get.find<SshController>().sftpDownload(path, local);
    if(!message.contains("OK") && context.mounted){
      showGeneralOk(context, "cantDownload".tr, message);
    }
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
}