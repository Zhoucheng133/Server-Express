import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/components/transfer_progress.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/ssh_controller.dart';

class FileItemM extends StatefulWidget {

  final FileClass file;
  final int index;
  
  const FileItemM({super.key, required this.file, required this.index});

  @override
  State<FileItemM> createState() => _FileItemMState();
}

class _FileItemMState extends State<FileItemM> {

  final FileController fileController=Get.find();

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

  void downloadHandler(BuildContext context) async {
    if(fileController.selectMode.value){
      fileController.files[widget.index].selcted=!fileController.files[widget.index].selcted;
      fileController.files.refresh();
    }else{
      if (context.mounted) {
        bool cancelled=false;
        showDialog(
          context: context, 
          barrierDismissible: false, 
          builder: (context)=>AlertDialog(
            title: Text("downloading".tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TransferProgressView(fallbackFileName: widget.file.name),
              ]
            ),
            actions: [
              TextButton(
                child: Text("cancel".tr),
                onPressed: (){
                  cancelled=true;
                  Get.find<SshController>().cancelTransfer();
                  Navigator.pop(context);
                },
              ),
            ],
          )
        );
        final message=await fileController.downloadFile(context, p.join(fileController.path.value, widget.file.name), fileController.downloadDir.value);
        if(context.mounted && !cancelled){
          if(message.contains("OK")){
            Navigator.pop(context);
          }else{
            Navigator.pop(context);
            showGeneralOk(context, "cantDownload".tr, message);
          }
        }
      }
    }
  }

  Future<void> openHandler(BuildContext context) async {
    if(fileController.selectMode.value){
      fileController.files[widget.index].selcted=!fileController.files[widget.index].selcted;
      fileController.files.refresh();
    }else if(widget.file.isDir){
      fileController.path.value=p.join(fileController.path.value, widget.file.name);
      fileController.getFiles(context);
    }else{
      final confirm=await showGeneralConfirm(context, "download".tr, "${"download".tr}: ${widget.file.name}", okText: "download".tr);
      if(confirm && context.mounted){
        downloadHandler(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Obx(
        ()=>Row(
          mainAxisSize: .min,
          children: [
            if(fileController.selectMode.value) Checkbox(
              value: widget.file.selcted,
              onChanged: (val){
                fileController.files[widget.index].selcted=val!;
                fileController.files.refresh();
              },
            ),
            widget.file.isDir ? Icon(Icons.folder_rounded) : Icon(Icons.insert_drive_file_rounded),
          ],
        ),
      ),
      title: Text(
        widget.file.name,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(widget.file.size != null ? formatSize(widget.file.size!) : ""),
      onTap: ()=>openHandler(context),
      onLongPress: (){
        fileController.selectMode.value=true;
        openHandler(context);
      },
    );
  }
}