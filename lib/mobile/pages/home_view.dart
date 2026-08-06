import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/add_server.dart';
import 'package:server_express/getx/server_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final ServerController serverController=Get.find();

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
        ListView.builder(
          itemCount: serverController.servers.length,
          itemBuilder: (context, index){
            return ListTile(
              title: Text(serverController.servers[index].name),
              subtitle: Text("${serverController.servers[index].addr}:${serverController.servers[index].port}"),
            );
          }
        )
      )
    );
  }
}