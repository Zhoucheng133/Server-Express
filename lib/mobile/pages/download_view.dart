import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/mobile/components/download_item_m.dart';
import 'package:share_plus/share_plus.dart';

class DownloadView extends StatefulWidget {
  const DownloadView({super.key});

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {

  final FileController fileController=Get.find();

  String rootPath="";
  String currentPath="";

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
    setState(() {
      currentPath=path;
    });
    await fileController.getLocalFiles(path);
  }

  void handleBack() async {
    if(currentPath==rootPath){
      return;
    }
    await loadDir(p.dirname(currentPath));
  }

  Future<void> openFile(FileClass file, int index) async {
    if(fileController.selectMode.value){
      fileController.localFiles[index].selcted=!fileController.localFiles[index].selcted;
      fileController.localFiles.refresh();
      return;
    }else if(file.isDir){
      await loadDir(p.join(currentPath, file.name));
      return;
    }else{
      await OpenFile.open(p.join(currentPath, file.name));
    }
  }

  void selectAll(BuildContext context) async {
    int selectCount=0;
    for(var file in fileController.localFiles){
      if(file.selcted){
        selectCount++;
      }
    }
    if(selectCount==fileController.localFiles.length){
      for(var file in fileController.localFiles){
        file.selcted=false;
      }
    }else{
      for(var file in fileController.localFiles){
        file.selcted=true;
      }
    }
    fileController.localFiles.refresh();
  }

  Future<void> deleteSelected(BuildContext context) async {
    int selectCount=fileController.localFiles.where((element) => element.selcted).length;
    if(selectCount==0){
      showGeneralOk(context, "noSelect".tr, "noSelectContent".tr);
      return;
    }
    bool ok=await showGeneralConfirm(context, "deleteSelected".tr, "deleteSelectedContent".tr, okText: 'delete'.tr);
    if(ok){
      for (var file in fileController.localFiles) {
        if(file.selcted && context.mounted){
          try {
            final String fullPath=p.join(currentPath, file.name);
            if(file.isDir){
              await Directory(fullPath).delete(recursive: true);
            }else{
              await File(fullPath).delete();
            }
          } catch (_) {
            if(context.mounted){
              showGeneralOk(context, "cantDelete".tr, file.name);
            }
          }
        }
      }
      if(context.mounted) await loadDir(currentPath);
      fileController.selectMode.value=false;
    }
  }

  Future<void> shareSelected(BuildContext context) async {
    int selectCount=fileController.localFiles.where((element) => element.selcted).length;
    if(selectCount==0){
      showGeneralOk(context, "noSelect".tr, "noSelectContent".tr);
      return;
    }
    List<XFile> files=[];
    for (var element in fileController.localFiles) {
      if(element.selcted){
        files.add(XFile(p.join(currentPath, element.name)));
      }
    }
    await SharePlus.instance.share(
      ShareParams(files: files),
    );
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
          leading: IconButton(
            onPressed: currentPath == rootPath ? null : handleBack,
            icon: Icon(Icons.arrow_back_rounded),
          ),
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
        bottomSheet: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Obx(()=>
            fileController.selectMode.value ?
            Container(
              height: 60 + MediaQuery.of(context).padding.bottom,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: Padding(
                padding: .only(left: 10.0, right: 10.0, bottom: MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => fileController.toggleSelectMode(), 
                      child: Text("unselect".tr)
                    ),
                    TextButton(
                      onPressed: () => selectAll(context), 
                      child: Text("selectAll".tr)
                    ),
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () => shareSelected(context), 
                      icon: Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => deleteSelected(context),
                      icon: Icon(
                        Icons.delete_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ) : SizedBox(),
          ),
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
                    return DownloadItemM(
                      index: index,
                      file: file, 
                      onTap: ()=>openFile(file, index),
                      loadDir: () => loadDir(currentPath),
                      currentPath: currentPath,
                    );
                  },
                ),
              ),
            ),
            Obx(
              () => fileController.selectMode.value ? SizedBox(
                height: 60,
              ) : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
