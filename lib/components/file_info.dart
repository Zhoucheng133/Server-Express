import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:server_express/components/file_item.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/general_controller.dart';

class FileInfo extends StatefulWidget {

  final FileClass item;

  const FileInfo({super.key, required this.item});

  @override
  State<FileInfo> createState() => _FileInfoState();
}

class InfoItem extends StatefulWidget {

  final String label;
  final String value;

  const InfoItem({super.key, required this.label, required this.value});

  @override
  State<InfoItem> createState() => _InfoItemState();
}

class _InfoItemState extends State<InfoItem> {
  @override
  Widget build(BuildContext context) {
    if(isDesktop()){
      return SizedBox(
        width: 400,
        child: Row(
          crossAxisAlignment: .start,
          mainAxisAlignment: .start,
          spacing: 10,
          children: [
            SizedBox(
              width: 70,
              child: Text(
                widget.label,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis
                ),
              ),
            ),
            Expanded(
              child: Tooltip(
                message: widget.value,
                child: Text(
                  widget.value,
                  maxLines: 3,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis
                  ),
                ),
              )
            )
          ],
        ),
      );
    }else{
      return Container();
    }
  }
}

class _FileInfoState extends State<FileInfo> {

  final FileController fileController=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 10,
      children: [
        InfoItem(label: "name".tr, value: widget.item.name),
        InfoItem(label: "path".tr, value: p.join(fileController.path.value, widget.item.name)),
        InfoItem(label: "type".tr, value: widget.item.isDir ? 'dir'.tr : 'file'),
        InfoItem(label: "size".tr, value: widget.item.isDir ? "/" : formatSize(widget.item.size!)),
      ],
    );
  }
}