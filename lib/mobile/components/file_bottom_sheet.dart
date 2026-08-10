import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/general.dart';
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
          Expanded(child: Container()),
          TextButton(
            onPressed: () => addFolder(context), 
            child: Text("addFolder".tr)
          ),
        ],
      ),
    );
  }
}