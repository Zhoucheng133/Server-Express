import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/getx/file_controller.dart';

class DownloadView extends StatefulWidget {
  const DownloadView({super.key});

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {

  final FileController fileController=Get.find();

  String rootPath="";
  String currentPath="";

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      rootPath=p.join((await getApplicationSupportDirectory()).path, "downloads");
      if (!await Directory(rootPath).exists()) {
        await Directory(rootPath).create(recursive: true);
      }
      fileController.downloadDir.value=rootPath;
      await loadDir(rootPath);
    });
  }

  Future<void> loadDir(String path) async {
    currentPath=path;
    await fileController.getLocalFiles(path);
  }

  void handleBack() async {
    if(currentPath==rootPath) return;
    await loadDir(p.dirname(currentPath));
  }

  Future<void> openFile(FileClass file) async {
    if(file.isDir){
      await loadDir(p.join(currentPath, file.name));
      return;
    }
    if(!context.mounted) return;
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      builder: (context)=>Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(file.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(p.join(currentPath, file.name)),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
            title: Text("delete".tr, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () async {
              Navigator.pop(context);
              await deleteFile(file);
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }

  Future<void> deleteFile(FileClass file) async {
    bool ok=await showGeneralConfirm(
      context, "deleteFileTitle".tr,
      "${'delete'.tr}: ${file.name}\n${'deleteFileContent'.tr}",
      okText: 'delete'.tr,
    );
    if(!ok || !mounted) return;
    String message="";
    try {
      final String path=p.join(currentPath, file.name);
      if(file.isDir){
        await Directory(path).delete(recursive: true);
      }else{
        await File(path).delete();
      }
      await loadDir(currentPath);
    } catch (_) {
      message="deleteFileContent".tr;
    }
    if(message.isNotEmpty && mounted){
      showGeneralOk(context, "cantDelete".tr, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String relative=p.relative(currentPath, from: rootPath);
    final List<String> parts=relative=="." ? <String>[] : p.split(relative);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if(fileController.path.value!="/"){
          handleBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          scrolledUnderElevation: 0.0,
          title: Text("download".tr),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: ()=>loadDir(currentPath),
                icon: Icon(Icons.refresh_rounded),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: parts.length+1,
                itemBuilder: (context, index){
                  if(index==0){
                    return TextButton(
                      onPressed: (){
                        loadDir(rootPath);
                      },
                      child: Text("download".tr),
                    );
                  }
                  return Row(
                    children: [
                      Text("/"),
                      TextButton(
                        onPressed: (){
                          loadDir([rootPath, ...parts.sublist(0, index)].join(p.separator));
                        },
                        child: Text(parts[index-1]),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Obx(
                ()=> fileController.localFiles.isEmpty ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_for_offline_outlined,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        "noDownload".tr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ) : ListView.builder(
                  itemCount: fileController.localFiles.length,
                  itemBuilder: (context, index){
                    final file=fileController.localFiles[index];
                    return ListTile(
                      leading: file.isDir ? Icon(Icons.folder_rounded) : Icon(Icons.insert_drive_file_rounded),
                      title: Text(
                        file.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(file.size != null ? formatSize(file.size!) : ""),
                      onTap: ()=>openFile(file),
                      onLongPress: ()=>openFile(file),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
