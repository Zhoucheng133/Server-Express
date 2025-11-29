import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/getx/file_controller.dart';

class FileItem extends StatefulWidget {

  final FileClass file;

  const FileItem({super.key, required this.file});

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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.file.isDir ? Icon(Icons.folder_rounded) : Icon(Icons.insert_drive_file_rounded),
      title: Text(widget.file.name),
      trailing: Text(widget.file.size != null ? formatSize(widget.file.size!) : ""),
      onTap: (){
        if(widget.file.isDir){
          Get.find<FileController>().path.value+="/${widget.file.name}";
          Get.find<FileController>().getFiles(context);
        }else{
          // TODO For file
        }
      },
    );
  }
}