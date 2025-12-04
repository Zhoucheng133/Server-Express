import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:path/path.dart' as p;

class FileItem extends StatefulWidget {

  final FileClass file;
  final int index;

  const FileItem({super.key, required this.file, required this.index});

  @override
  State<FileItem> createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> {

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

  final FileController fileController=Get.find();

  Future<void> showFuncMenu(BuildContext context, TapDownDetails details) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = overlay.localToGlobal(details.globalPosition);
    var val=await showMenu(
      context: context,
      // 菜单位置
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 50,
        position.dy + 50,
      ),
      items: [
        PopupMenuItem(
          height: 35,
          value: "open",
          child: Row(
            children: [
              Icon(
                widget.file.isDir ?  Icons.open_in_new_rounded : Icons.download_rounded,
                size: 20,
              ),
              const SizedBox(width: 5,),
              Text(widget.file.isDir ? 'open'.tr : 'download'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          height: 35,
          value: "rename",
          child: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                size: 20,
              ),
              const SizedBox(width: 5,),
              Text('rename'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          height: 35,
          value: "copyPath",
          child: Row(
            children: [
              Icon(
                Icons.copy_rounded,
                size: 20,
              ),
              const SizedBox(width: 5,),
              Text('copyPath'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          height: 35,
          value: "copyDirPath",
          child: Row(
            children: [
              Icon(
                Icons.copy_rounded,
                size: 20,
              ),
              const SizedBox(width: 5,),
              Text('copyDirPath'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          height: 35,
          value: "delete",
          child: Row(
            children: [
              Icon(
                Icons.delete_rounded,
                size: 20,
              ),
              const SizedBox(width: 5,),
              Text('delete'.tr),
            ],
          ),
        ),
      ]
    );
    switch (val) {
      case "open":
        if(context.mounted) openHandler(context);
        break;
      case "rename":
        if(context.mounted) fileController.renameFile(context, p.join(fileController.path.value, widget.file.name));
        break;
      case "delete":
        if(context.mounted) fileController.deleteFile(context, p.join(fileController.path.value, widget.file.name));
        break;
      case "copyPath":
        await FlutterClipboard.copy(p.join(fileController.path.value, widget.file.name));
      case "copyDirPath":
        await FlutterClipboard.copy(fileController.path.value);
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
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null && context.mounted) {
        fileController.downloadFile(context, p.join(fileController.path.value, widget.file.name), selectedDirectory);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (val)=>showFuncMenu(context, val),
      child: Tooltip(
        message: widget.file.name,
        waitDuration: Duration(milliseconds: 500),
        child: ListTile(
          leading: Obx(()=>
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(fileController.selectMode.value) Checkbox(
                  splashRadius: 0,
                  value: widget.file.selcted,
                  onChanged: (val){
                    fileController.files[widget.index].selcted=val!;
                    fileController.files.refresh();
                  },
                ),
                widget.file.isDir ? Icon(Icons.folder_rounded) : Icon(Icons.insert_drive_file_rounded)
              ],
            ),
          ),
          title: Text(
            widget.file.name,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(widget.file.size != null ? formatSize(widget.file.size!) : ""),
          onTap: ()=>openHandler(context)
        ),
      ),
    );
  }
}