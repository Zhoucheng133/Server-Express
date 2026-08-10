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

    final navigator = Navigator.of(context);
    bool cancelled=false;

    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context)=>AlertDialog(
        title: Text("downloading".tr),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TransferProgressView(fallbackFileName: widget.file.name),
            ]
          ),
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
    if(!cancelled){
      if(message.contains("OK")){
        navigator.pop();
      }else{
        navigator.pop();
        if(context.mounted){
          showGeneralOk(context, "cantDownload".tr, message);
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

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (context)=>Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.download_rounded),
            title: Text("download".tr),
            onTap: (){
              Navigator.pop(context);
              downloadHandler(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_rounded),
            title: Text("delete".tr),
            onTap: (){
              Navigator.pop(context);
              fileController.deleteFile(context, p.join(fileController.path.value, widget.file.name));
            },
          ),
          ListTile(
            leading: Icon(Icons.edit_rounded),
            title: Text("rename".tr),
            onTap: (){
              Navigator.pop(context);
              fileController.renameFile(context, p.join(fileController.path.value, widget.file.name));
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ]
      )
    );
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
      subtitle: widget.file.size != null ? Text(formatSize(widget.file.size!)) : null,
      trailing: Transform.translate(
        offset: Offset(10, 0),
        child: IconButton(
          onPressed: ()=>showBottomSheet(context), 
          icon: Icon(Icons.more_vert_rounded)
        )
      ),
      onTap: ()=>openHandler(context),
      onLongPress: (){
        fileController.selectMode.value=true;
        openHandler(context);
      },
    );
  }
}