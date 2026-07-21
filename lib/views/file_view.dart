import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/components/file_item.dart';
import 'package:server_express/components/header/file_header.dart';
import 'package:server_express/components/transfer_progress.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:path/path.dart' as p;
import 'package:server_express/getx/ssh_controller.dart';

class FileView extends StatefulWidget {
  const FileView({super.key});

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {

  final FileController fileController=Get.find();
  final ServerController serverController=Get.find();
  final SshController sshController=Get.find();

  RxString progressFileName=RxString("");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fileController.getFiles(context);
    });
  }

  Future<void> dragUpload(BuildContext context, List<DropItem> files) async {
    bool upload=await showGeneralConfirm(context, "upload".tr, "upload_content".tr);
    if(upload){
      List<String> paths=[];
      for(var file in files){
        paths.add(file.path);
      }
      if(context.mounted){
        bool cancelled=false;
        showDialog(
          context: context, 
          barrierDismissible: false, 
          builder: (context)=>AlertDialog(
            title: Text("uploading".tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => TransferProgressView(
                    fallbackFileName: progressFileName.value,
                  ),
                ),
              ]
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
          )
        );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        dragUpload(context, detail.files);
      },
      child: Obx(
        ()=>Column(
          children: [
            FileHeader(),
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: p.split(fileController.path.value).length,
                itemBuilder: (BuildContext context, int index){
                  if(index==0){
                    return TextButton(
                      onPressed: (){
                        fileController.path.value = "/";
                        fileController.getFiles(context);
                        fileController.selectMode.value = false;
                        fileController.getFiles(context);
                      }, 
                      child: Text("Root")
                    );
                  }else{
                    return Row(
                      children: [
                        Text("/"),
                        TextButton(
                          onPressed: (){
                            fileController.path.value = p.split(fileController.path.value).sublist(0, index+1).join("/");
                            fileController.selectMode.value = false;
                            fileController.getFiles(context);
                          }, 
                          child: Text(p.split(fileController.path.value)[index])
                        )
                      ],
                    );
                  }
                }
              )
            ),
            Expanded(
              child: ListView.builder(
                itemCount: fileController.files.length,
                itemBuilder: (BuildContext context, int index) {
                  return FileItem(file: fileController.files[index], index: index,);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}