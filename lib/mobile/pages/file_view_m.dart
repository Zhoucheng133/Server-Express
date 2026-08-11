import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:server_express/getx/ssh_controller.dart';
import 'package:server_express/mobile/components/file_bottom_sheet.dart';
import 'package:server_express/mobile/components/file_item_m.dart';

class FileViewM extends StatefulWidget {
  const FileViewM({super.key});

  @override
  State<FileViewM> createState() => _FileViewMState();
}

class _FileViewMState extends State<FileViewM> {

  final FileController fileController=Get.find();
  final ServerController serverController=Get.find();
  final SshController sshController=Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fileController.getFiles(context);
    });
  }

  Future<void> handleBack() async {
    fileController.selectMode.value=false;
    fileController.path.value=p.dirname(fileController.path.value);
    await fileController.getFiles(context);
  }

  void disconnectServer(BuildContext context) async {
    bool ok=await showGeneralConfirm(context, "disconnect".tr, "disconnectContent".tr);
    if(ok){
      await sshController.disconnect();
      fileController.selectMode.value=false;
      serverController.nowServer.value=null;
      fileController.path.value="/";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if(fileController.path.value=="/"){
            disconnectServer(context);
          }else{
            handleBack();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 0.0,
            title: Text(
              serverController.nowServer.value?.name ?? "",
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              onPressed: fileController.path.value=="/" ? null : handleBack, 
              icon: Icon(Icons.arrow_back_rounded)
            ),
            actions: [
              Padding(
                padding: .only(right: 10.0),
                child: IconButton(
                  onPressed: () => disconnectServer(context), 
                  icon: Icon(Icons.logout_rounded)
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
                child: RefreshIndicator(
                  onRefresh: () => fileController.getFiles(context),
                  child: ListView.builder(
                    itemCount: fileController.files.length,
                    itemBuilder: (context, index)=>FileItemM(file: fileController.files[index], index: index,)
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              )
            ],
          ),
          bottomSheet: Container(
            height: 60 + MediaQuery.of(context).padding.bottom,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Padding(
              padding: .only(bottom: MediaQuery.of(context).padding.bottom, left: 15, right: 15),
              child: FileBottomSheet(),
            ),
          ),
        ),
      ),
    );
  }
}