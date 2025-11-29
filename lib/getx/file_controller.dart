import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:server_express/desktop/components/dialogs/general.dart';
import 'package:server_express/getx/ssh_controller.dart';

class FileClass{
  String name;
  bool isDir;
  int? size;
  FileClass({required this.name, required this.isDir, required this.size});

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
  };
}

class FileController extends GetxController {
  RxString path="/".obs;
  RxList<FileClass> files=<FileClass>[].obs;

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
}