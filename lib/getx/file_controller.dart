import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/components/transfer_progress.dart';
import 'package:server_express/getx/general_controller.dart';
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

enum ClipBoardAction{
  none,
  copy,
  move
}

class FileController extends GetxController {
  RxString path="/".obs;
  RxList<FileClass> files=<FileClass>[].obs;
  RxBool selectMode=false.obs;

  Rx<ClipBoardAction> clipboardAction=Rx(ClipBoardAction.none);
  String? clipboardSourcePath;
  List<FileClass> clipboardFiles = [];

  // 移动端
  RxString downloadDir="".obs;
  RxList<FileClass> localFiles=<FileClass>[].obs;

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

  Future<void> getLocalFiles(String path) async {
    final directory=Directory(path);
    if(!await directory.exists()) return;
    List<FileClass> list=[];
    await for (final entity in directory.list()) {
      if(entity is File){
        list.add(FileClass(name: p.basename(entity.path), isDir: false, size: entity.lengthSync()));
      }else if(entity is Directory){
        list.add(FileClass(name: p.basename(entity.path), isDir: true, size: null));
      }
    }
    list.sort((a, b){
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
    localFiles.value=list;
  }

  bool checkDownload(List<String> fileNames, String local){
    final directory=Directory(local);
    for (var entity in directory.listSync()) {
      if (entity is File) {
        final name = p.basename(entity.path);
        if (fileNames.contains(name)) {
          return false;
        }
      }
    }
    return true;
  }

  Future<String> downloadFile(BuildContext context, String path, String local) async {
    if(!checkDownload([p.basename(path)], local)){
      return "ERR: ${p.basename(path)} ${'alreadyExists'.tr}";
    }

    return await Get.find<SshController>().sftpDownload(path, local);
  }

  Future<void> deleteFile(BuildContext context, String path) async { 
    bool ok=await showGeneralConfirm(
      context, "deleteFileTitle".tr, 
      "${'delete'.tr}: ${p.basename(path)}\n${'deleteFileContent'.tr}", 
      okText: 'delete'.tr, 
    );
    if(ok){
      String message=await Get.find<SshController>().sftpDelete(path);
      if(!message.contains("OK")){
        showGeneralOk(Get.context!, "cantDelete".tr, message);
      }else{
        getFiles(Get.context!);
      }
    }
  }

  Future<void> renameFile(BuildContext context, String path) async {
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
            onSubmitted: (val) async {
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
              if(!message.contains("OK")){
                showGeneralOk(Get.context!, "renameFail".tr, message);
              }else{
                Navigator.pop(Get.context!);
                getFiles(Get.context!);
              }
            }, 
            child: Text('rename'.tr)
          )
        ],
      )
    );
  }

  Future<void> deleteSelected(BuildContext context) async {
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
  bool _downloadCancelled=false;

  void toggleSelectMode(){
    selectMode.value=!selectMode.value;
    for (var file in files) {
      file.selcted=false;
    } 
    for (var file in localFiles) {
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

    String? selectedDirectory = isDesktop() ? await FilePicker.platform.getDirectoryPath() : downloadDir.value;
    if (selectedDirectory != null && context.mounted) {

      final List<String> selectedFiles = files.where((element) => element.selcted).toList().map((item)=>item.name).toList();
      if(!checkDownload(selectedFiles, selectedDirectory)){
        showGeneralOk(context, "cantDownload".tr, 'alreadyExists'.tr);
        return;
      }

      _downloadCancelled=false;
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (context)=>AlertDialog(
          title: Text("downloading".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(()=>Text("${downloadIndex.value} / ${downloadCount.value}")),
              Obx(
                () => TransferProgressView(
                  fallbackFileName: nowDownloadFile.value,
                ),
              ),
            ]
          ),
          actions: [
            TextButton(
              child: Text("cancel".tr),
              onPressed: (){
                _downloadCancelled=true;
                Get.find<SshController>().cancelTransfer();
                Navigator.pop(context);
              },
            ),
          ],
        )
      );
      String message="";
      for (var file in files) {
        if(_downloadCancelled) break;
        if(file.selcted){
          nowDownloadFile.value=file.name;
          message=await downloadFile(context, p.join(path.value, file.name), selectedDirectory);
          if(!message.contains("OK")){
            break;
          }
          downloadIndex.value++;
        }
      }
      if(context.mounted){
        if(!_downloadCancelled && message.contains("OK")){
          Navigator.pop(context);
        }else if(!_downloadCancelled){
          Navigator.pop(context);
          showGeneralOk(context, "cantDownload".tr, message);
        }
      }

      selectMode.value=false;
      nowDownloadFile.value="";
      downloadCount.value=0;
      downloadIndex.value=0;
    }
  }

  void prepareCopy(BuildContext context, List<FileClass> selectedFiles) {
    if (selectedFiles.isEmpty) return;
    clipboardAction.value=ClipBoardAction.copy;
    clipboardSourcePath = path.value;
    clipboardFiles = selectedFiles;
    selectMode.value = false;
  }

  void prepareMove(BuildContext context, List<FileClass> selectedFiles) {
    if (selectedFiles.isEmpty) return;
    clipboardAction.value=ClipBoardAction.move;
    clipboardSourcePath = path.value;
    clipboardFiles = selectedFiles;
    selectMode.value = false;
  }

  void prepareCopySingle(BuildContext context, FileClass file) {
    clipboardAction.value=ClipBoardAction.copy;
    clipboardSourcePath = path.value;
    clipboardFiles = [file];
  }

  void prepareMoveSingle(BuildContext context, FileClass file) {
    clipboardAction.value=ClipBoardAction.move;
    clipboardSourcePath = path.value;
    clipboardFiles = [file];
  }

  void cancelCopyMove(){
    clipboardAction.value=ClipBoardAction.none;
    clipboardFiles = [];
  }

  Future<void> pasteFiles(BuildContext context) async {
    if (clipboardAction.value == ClipBoardAction.none || clipboardFiles.isEmpty || clipboardSourcePath == null) {
      return;
    }
    final sshController = Get.find<SshController>();
    final filesJson = jsonEncode(clipboardFiles.map((item)=>item.name).toList());
    final isCopy = clipboardAction.value == ClipBoardAction.copy;
    
    bool cancelled = false;
    RxString progressFileName = RxString(clipboardFiles.first.name);

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(isCopy ? "copy".tr : "move".tr),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => TransferProgressView(
                    fallbackFileName: progressFileName.value,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("cancel".tr),
              onPressed: () {
                cancelled = true;
                sshController.cancelTransfer();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    String msg = "";
    if (isCopy) {
      msg = await sshController.sftpCopy(clipboardSourcePath!, path.value, filesJson);
    } else {
      msg = await sshController.sftpMove(clipboardSourcePath!, path.value, filesJson);
    }

    if (context.mounted && !cancelled) {
      Navigator.pop(context);
    }

    if (msg.contains("OK") || cancelled) {
      clipboardAction.value = ClipBoardAction.none;
      clipboardFiles = [];
      clipboardSourcePath = null;
      if (context.mounted) {
        getFiles(context);
      }
    } else {
      if (context.mounted) {
        showGeneralOk(context, isCopy ? "copyFail".tr : "moveFail".tr, msg);
      }
    }
  }
}