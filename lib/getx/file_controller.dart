import 'dart:convert';

import 'package:get/get.dart';
import 'package:server_express/getx/ssh_controller.dart';

class FileItem{
  String name;
  // type: 'file' & 'dir'
  // String type;
  bool isDir;
  int? size;
  FileItem({required this.name, required this.isDir, required this.size});

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
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
  RxList<FileItem> files=<FileItem>[].obs;

  Future<void> getFiles() async {
    final SshController sshController=Get.find();
    final String json=await sshController.sftpList(path.value);
    final List<dynamic> list=jsonDecode(json);
    files.value=list.map((item)=>FileItem.fromJson(item)).toList();
  }
}