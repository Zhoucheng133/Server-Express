import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/desktop/components/file_item.dart';
import 'package:server_express/desktop/components/header/file_header.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';

class FileView extends StatefulWidget {
  const FileView({super.key});

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {

  final FileController fileController=Get.find();
  final ServerController serverController=Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fileController.getFiles(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=>Column(
        children: [
          FileHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: fileController.files.length,
              itemBuilder: (BuildContext context, int index) {
                return FileItem(file: fileController.files[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}