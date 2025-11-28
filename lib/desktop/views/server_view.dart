import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/desktop/components/header.dart';
import 'package:server_express/desktop/components/server_item.dart';
import 'package:server_express/getx/server_controller.dart';

class ServerView extends StatefulWidget {
  const ServerView({super.key});

  @override
  State<ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {

  final ServerController serverController=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(title: "serverList".tr),
        Expanded(
          child: Obx(()=>
            GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                mainAxisExtent: 100
              ),
              itemBuilder: (context, index) {
                return ServerItem(server: serverController.servers[index]);
              },
              itemCount: serverController.servers.length,
            )
          )
        )
      ],
    );
  }
}