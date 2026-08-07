import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:server_express/mobile/components/file_item_m.dart';

class FileViewM extends StatefulWidget {
  const FileViewM({super.key});

  @override
  State<FileViewM> createState() => _FileViewMState();
}

class _FileViewMState extends State<FileViewM> {

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
      ()=> Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          scrolledUnderElevation: 0.0,
          title: Text(
            serverController.nowServer.value?.name ?? "",
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            onPressed: fileController.path.value=="/" ? null : () async {
              fileController.path.value=p.dirname(fileController.path.value);
              await fileController.getFiles(context);
            }, 
            icon: Icon(Icons.arrow_back_rounded)
          ),
        ),
        body: ListView.builder(
          itemCount: fileController.files.length,
          itemBuilder: (context, index)=>FileItemM(file: fileController.files[index], index: index,)
        ),
      ),
    );
  }
}