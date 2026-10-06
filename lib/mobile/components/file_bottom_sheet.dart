import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/components/transfer_progress.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/ssh_controller.dart';

class FileBottomSheet extends StatefulWidget {
  const FileBottomSheet({super.key});

  @override
  State<FileBottomSheet> createState() => _FileBottomSheetState();
}

class _FileBottomSheetState extends State<FileBottomSheet> {

  final fileController=Get.find<FileController>();
  final sshController=Get.find<SshController>();

  // 上传相关
  RxString progressFileName=RxString("");

  void addFolder(BuildContext context){
    TextEditingController controller=TextEditingController();
    FocusNode focusNode=FocusNode();
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text("addFolder".tr),
        content: StatefulBuilder(
          builder: (context, setState)=>TextField(
            decoration: InputDecoration(
              labelText: "name".tr,
            ),
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (String val) async {
              if(controller.text.isEmpty){
                showGeneralOk(context, "addFolderFail".tr, "nameNotEmpty".tr);
                return;
              }else if(fileController.files.any((file) => file.name==controller.text)){
                showGeneralOk(context, "addFolderFail".tr, "fileNameRepeat".tr);
                return;
              }else{
                await sshController.sftpMkdir(fileController.path.value, controller.text);
                if(context.mounted) fileController.getFiles(context);
                if(context.mounted) Navigator.pop(context);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: Text('cancel'.tr)
          ),
          ElevatedButton(
            onPressed: () async {
              if(controller.text.isEmpty){
                showGeneralOk(context, "addFolderFail".tr, "nameNotEmpty".tr);
                return;
              }else if(fileController.files.any((file) => file.name==controller.text)){
                showGeneralOk(context, "addFolderFail".tr, "fileNameRepeat".tr);
                return;
              }else{
                await sshController.sftpMkdir(fileController.path.value, controller.text);
                if(context.mounted) fileController.getFiles(context);
                if(context.mounted) Navigator.pop(context);
              }
            }, 
            child: Text('ok'.tr)
          )
        ]
      )
    );
    focusNode.requestFocus();
  }

  void selectAll(BuildContext context) async {
    int selectCount=0;
    for(var file in fileController.files){
      if(file.selcted){
        selectCount++;
      }
    }
    if(selectCount==fileController.files.length){
      for(var file in fileController.files){
        file.selcted=false;
      }
    }else{
      for(var file in fileController.files){
        file.selcted=true;
      }
    }
    fileController.files.refresh();
  }

  bool matchName(List<String> names){
    List listNames = fileController.files.map((file) => file.name).toList();
    return names.any((name) => listNames.contains(name));
  }

  Future<void> uploadHandler(BuildContext context, List<String> paths) async {
    List<String> fileNames=paths.map((path) => p.basename(path)).toList();
      
    if(matchName(fileNames) && context.mounted){
      showGeneralOk(context, "uploadFail".tr, "fileNameRepeat".tr);
      return;
    }
    
    bool cancelled=false;
    if(context.mounted){
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (context)=>AlertDialog(
          title: Text("uploading".tr),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => TransferProgressView(
                    fallbackFileName: progressFileName.value,
                  ),
                ),
              ]
            ),
          ),
          actions: [
            TextButton(
              child: Text("cancel".tr),
              onPressed: (){
                cancelled=true;
                sshController.cancelTransfer();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    for(String path in paths){
      if(cancelled) break;
      progressFileName.value=p.basename(path);
      String msg=await sshController.sftpUpload(p.join(fileController.path.value, p.basename(path)), path);
      if(context.mounted && (msg.contains("OK") || cancelled)){
        await fileController.getFiles(context);
      }else if(context.mounted){
        showGeneralOk(context, "uploadFail".tr, msg);
      }
    }

    if(context.mounted && !cancelled) Navigator.pop(context);
    progressFileName.value = "";
  }

  Future<void> uploadFromFile(BuildContext context) async {
    // FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    List<PlatformFile> files = await FilePicker.pickFiles();
    if (files.isNotEmpty && context.mounted) {
      // List<String> paths = result.paths.whereType<String>().toList();
      List<String> paths = files.map((item)=>item.path!).toList();
      await uploadHandler(context, paths);
    }
  }

  Future<void> uploadFromPhotos(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();
    
    if (context.mounted && selectedImages.isNotEmpty) {
      List<String> paths = selectedImages.map((item)=> item.path).toList();
      await uploadHandler(context, paths);
    }
  }

  Future<void> uploadFromDownloads(BuildContext context) async {
    String downloadPath=fileController.downloadDir.value;
    if(downloadPath.isEmpty){
      downloadPath=p.join((await getApplicationSupportDirectory()).path, "downloads");
    }
    if(!await Directory(downloadPath).exists()){
      await Directory(downloadPath).create(recursive: true);
    }
    if(!context.mounted) return;
    final paths=await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DownloadUploadPicker(rootPath: downloadPath),
    );
    if(context.mounted && paths!=null && paths.isNotEmpty){
      await uploadHandler(context, paths);
    }
  }

  void upload(BuildContext context){

    final rootContext=context;

    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      builder: (context)=>Column(
        mainAxisSize: .min,
        children: [
          ListTile(
            leading: Icon(Icons.insert_drive_file_rounded),
            title: Text("fromFile".tr),
            onTap: (){
              Navigator.pop(context);
              uploadFromFile(rootContext);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_rounded),
            title: Text("fromPhotos".tr),
            onTap: (){
              Navigator.pop(context);
              uploadFromPhotos(rootContext);
            },
          ),
          ListTile(
            leading: Icon(Icons.download_rounded),
            title: Text("download".tr),
            onTap: (){
              Navigator.pop(context);
              uploadFromDownloads(rootContext);
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> fileController.selectMode.value ? Row(
        crossAxisAlignment: .center,
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
            onPressed: () => fileController.downloadSelected(context), 
            icon: Icon(
              Icons.download_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => fileController.prepareCopy(context, fileController.files.where((e) => e.selcted).toList()),
            icon: Icon(
              Icons.copy_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => fileController.prepareMove(context, fileController.files.where((e) => e.selcted).toList()),
            icon: Icon(
              Icons.drive_file_move_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => fileController.deleteSelected(context),
            icon: Icon(
              Icons.delete_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        ) : Row(
          crossAxisAlignment: .center,
          children: [
            if (fileController.clipboardAction.value == ClipBoardAction.none) TextButton(
              onPressed: () => fileController.toggleSelectMode(), 
              child: Text("select".tr)
            ),
            if (fileController.clipboardAction.value != ClipBoardAction.none) TextButton(
              onPressed: () => fileController.cancelCopyMove(),
              child: Text("cancel".tr)
            ),
            if (fileController.clipboardAction.value != ClipBoardAction.none && fileController.clipboardFiles.isNotEmpty)
              TextButton(
                onPressed: () => fileController.pasteFiles(context),
                child: Text(fileController.clipboardAction.value==ClipBoardAction.copy ? "paste".tr : "move".tr,),
              ),
            Expanded(child: Container()),
            if (fileController.clipboardAction.value == ClipBoardAction.none) TextButton(
              onPressed: ()=>upload(context), 
              child: Text("upload".tr)
            ),
            TextButton(
              onPressed: () => addFolder(context), 
              child: Text("addFolder".tr)
            ),
          ],
      ),
    );
  }
}

class _DownloadUploadPicker extends StatefulWidget {
  final String rootPath;

  const _DownloadUploadPicker({required this.rootPath});

  @override
  State<_DownloadUploadPicker> createState() => _DownloadUploadPickerState();
}

class _DownloadUploadPickerState extends State<_DownloadUploadPicker> {
  late String currentPath;
  List<FileSystemEntity> files=[];
  final Set<String> selectedPaths={};
  bool loading=true;

  @override
  void initState() {
    super.initState();
    currentPath=widget.rootPath;
    loadFiles();
  }

  Future<void> loadFiles() async {
    setState(() {
      loading=true;
    });
    final items=await Directory(currentPath).list().toList();
    items.sort((a, b){
      if(a is Directory && b is! Directory) return -1;
      if(a is! Directory && b is Directory) return 1;
      return p.basename(a.path).compareTo(p.basename(b.path));
    });
    if(mounted){
      setState(() {
        files=items;
        loading=false;
      });
    }
  }

  Future<void> openDirectory(String path) async {
    currentPath=path;
    await loadFiles();
  }

  Future<void> goBack() async {
    if(p.equals(currentPath, widget.rootPath)) return;
    currentPath=p.dirname(currentPath);
    await loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.8,
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Padding(
                padding: .symmetric(horizontal: 5),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: p.equals(currentPath, widget.rootPath) ? null : goBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: Text("download".tr)
                    ),
                    TextButton(
                      onPressed: selectedPaths.isEmpty ? null : () => Navigator.pop(context, selectedPaths.toList()),
                      child: Text("upload".tr),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index){
                  final file=files[index];
                  final isDirectory=file is Directory;
                  final isSelected=selectedPaths.contains(file.path);
                  return ListTile(
                    title: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: isDirectory ? const Icon(Icons.folder_rounded) : Checkbox(
                            value: isSelected,
                            onChanged: (value){
                              setState(() {
                                if(value==true){
                                  selectedPaths.add(file.path);
                                }else{
                                  selectedPaths.remove(file.path);
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            p.basename(file.path),
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                      ],
                    ),
                    onTap: isDirectory ? () => openDirectory(file.path) : (){
                      setState(() {
                        if(isSelected){
                          selectedPaths.remove(file.path);
                        }else{
                          selectedPaths.add(file.path);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
