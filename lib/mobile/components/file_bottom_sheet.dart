import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && context.mounted) {
      List<String> paths = result.paths.whereType<String>().toList();
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
            TextButton(
              onPressed: () => fileController.toggleSelectMode(), 
              child: Text("select".tr)
            ),
            if (fileController.clipboardAction.value != ClipBoardAction.none && fileController.clipboardFiles.isNotEmpty)
              TextButton(
                onPressed: () => fileController.pasteFiles(context),
                child: Text("paste".tr),
              ),
            Expanded(child: Container()),
            TextButton(
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