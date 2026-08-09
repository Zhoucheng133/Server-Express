import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/add_server.dart';
import 'package:server_express/components/dialogs/edit_server.dart';
import 'package:server_express/components/dialogs/general.dart';
import 'package:server_express/getx/server_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final ServerController serverController=Get.find();

  Future<void> connect(BuildContext context, Server server) async {
    String message=await serverController.serverCheck(context, server.addr, server.port, server.username, server.password);
    if(message.contains("OK") && context.mounted){
      serverController.nowServer.value=server;
    }else if(context.mounted){
      showGeneralOk(context, "loginFailTitle".tr, message);
    }
  }

  void showServerOption(BuildContext context, int index){
    showModalBottomSheet(
      context: context, 
      clipBehavior: Clip.antiAlias,
      builder: (context)=> Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("edit".tr),
            onTap: (){
              Navigator.pop(context);
              showEditServer(context, serverController.servers[index]);
            },
          ),
          ListTile(
            title: Text("delete".tr),
            onTap: () async {
              Navigator.pop(context);
              bool del=await showGeneralConfirm(context, "delServerTitle".tr, "delServerContent".tr);
              if(del){
                serverController.removeServer(serverController.servers[index].id);
              }
            }
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("home".tr),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_rounded),
        onPressed: ()=>showAddServer(context),
      ),
      body: Obx(()=>
        serverController.servers.isEmpty ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            mainAxisSize: .min,
            children: [
              Icon(
                Icons.dns_rounded, 
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                "noServer".tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16
                ),
              ),
            ],
          ),
        ) : ListView.builder(
          itemCount: serverController.servers.length,
          itemBuilder: (context, index){
            return ListTile(
              title: Text(serverController.servers[index].name),
              subtitle: Text("${serverController.servers[index].addr}:${serverController.servers[index].port}"),
              onTap: ()=>connect(context, serverController.servers[index]),
              onLongPress: ()=>showServerOption(context, index), 
              trailing: Transform.translate(
                offset: Offset(10, 0),
                child: IconButton(
                  onPressed: ()=>showServerOption(context, index), 
                  icon: Icon(Icons.more_vert_rounded)
                ),
              ),
            );
          }
        )
      )
    );
  }
}