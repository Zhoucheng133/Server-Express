import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:share_plus/share_plus.dart';

class DownloadItemM extends StatefulWidget {

  final FileClass file;
  final VoidCallback onTap;
  final Future<void> Function() loadDir;
  final String currentPath;
  final int index;

  const DownloadItemM({super.key, required this.file, required this.onTap, required this.loadDir, required this.currentPath, required this.index});

  @override
  State<DownloadItemM> createState() => _DownloadItemMState();
}

class _DownloadItemMState extends State<DownloadItemM> {

  final FileController fileController=Get.find();

  Future<void> deleteFile(FileClass file) async {
    bool ok=await showGeneralConfirm(
      context, "deleteFileTitle".tr,
      "${'delete'.tr}: ${file.name}\n${'deleteFileContent'.tr}",
      okText: 'delete'.tr,
    );
    if(!ok || !mounted) return;
    String message="";
    try {
      final String path=p.join(widget.currentPath, file.name);
      if(file.isDir){
        await Directory(path).delete(recursive: true);
      }else{
        await File(path).delete();
      }
      await widget.loadDir();
    } catch (_) {
      message="deleteFileContent".tr;
    }
    if(message.isNotEmpty && mounted){
      showGeneralOk(context, "cantDelete".tr, message);
    }
  }

  void renameFile(BuildContext context, FileClass file) async {
    final controller=TextEditingController(text: file.name);
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
              String message="";
              try {
                final String oldPath=p.join(widget.currentPath, file.name);
                final String newPath=p.join(widget.currentPath, controller.text);
                if(file.isDir){
                  await Directory(oldPath).rename(newPath);
                }else{
                  await File(oldPath).rename(newPath);
                }
                await widget.loadDir();
              } catch (_) {
                message="renameFail".tr;
              }
              if(context.mounted && message.isNotEmpty){
                showGeneralOk(context, "renameFail".tr, message);
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
              String message="";
              try {
                final String oldPath=p.join(widget.currentPath, file.name);
                final String newPath=p.join(widget.currentPath, controller.text);
                if(file.isDir){
                  await Directory(oldPath).rename(newPath);
                }else{
                  await File(oldPath).rename(newPath);
                }
                if(context.mounted) Navigator.pop(context);
                await widget.loadDir();
              } catch (_) {
                message="renameFail".tr;
              }
              if(context.mounted && message.isNotEmpty){
                showGeneralOk(context, "renameFail".tr, message);
              }
            },
            child: Text('rename'.tr)
          )
        ],
      )
    );
  }

  String formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const units = ["B", "KB", "MB", "GB", "TB"];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    String result = size.toStringAsFixed(2);
    result = result.replaceFirst(RegExp(r'\.?0+$'), '');

    return "$result ${units[unitIndex]}";
  }

  void showButtonSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.open_in_new_rounded),
              title: Text("open".tr),
              onTap: (){
                Navigator.of(context).pop();
                OpenFile.open(p.join(widget.currentPath, widget.file.name));
              }
            ),
            ListTile(
              leading: Icon(Icons.share_rounded),
              title: Text("share".tr),
              onTap: () async {
                Navigator.of(context).pop();
                final file = XFile(p.join(widget.currentPath, widget.file.name));
                await SharePlus.instance.share(
                  ShareParams(files: [file]),
                );
              }
            ),
            ListTile(
              leading: Icon(Icons.edit_rounded),
              title: Text("rename".tr),
              onTap: (){
                Navigator.of(context).pop();
                renameFile(context, widget.file);
              }
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded),
              title: Text("delete".tr),
              onTap: () async {
                Navigator.of(context).pop();
                deleteFile(widget.file);
              }
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(()=>
            fileController.selectMode.value ? Checkbox(
              value: widget.file.selcted,
              onChanged: (val){
                fileController.localFiles[widget.index].selcted=val!;
                fileController.localFiles.refresh();
              },
            ) : Container(),
          ),
          widget.file.isDir ? Icon(Icons.folder_rounded) : Icon(Icons.insert_drive_file_rounded)
        ],
      ),
      title: Text(
        widget.file.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: widget.file.isDir ? null : Text(formatSize(widget.file.size!)),
      onTap: widget.onTap,
      onLongPress: (){
        fileController.selectMode.value=true;
        fileController.localFiles[widget.index].selcted=true;
      },
      trailing: Transform.translate(
        offset: Offset(10, 0),
        child: IconButton(
          onPressed: ()=>showButtonSheet(context),
          icon: Icon(Icons.more_vert_rounded),
        ),
      ),
    );
  }
}