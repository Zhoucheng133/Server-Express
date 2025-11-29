import 'dart:convert';

import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
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

  Future<void> getFiles() async {
    final SshController sshController=Get.find();
    final String json=await sshController.sftpList(path.value);
    final List<dynamic> list=jsonDecode(json);
    files.value=list.map((item)=>FileClass.fromJson(item)).toList();
    files.sort((a, b){
      if (a.isDir && !b.isDir) {
        return -1;
      }
      // a 是文件, b 是文件夹: b 应该在前 (返回 1)
      if (!a.isDir && b.isDir) {
        return 1;
      }
      final String nameA = PinyinHelper.getPinyinE(a.name, separator: '').toLowerCase();
      final String nameB = PinyinHelper.getPinyinE(b.name, separator: '').toLowerCase();

      // 使用 Dart 的 String compareTo 方法进行 A-Z 比较
      return nameA.compareTo(nameB);
    });
  }
}