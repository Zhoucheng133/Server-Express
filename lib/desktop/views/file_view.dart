import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/desktop/components/file_item.dart';
import 'package:server_express/desktop/components/header/file_header.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';
import 'package:path/path.dart' as p;

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
                return FileItem(file: fileController.files[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}