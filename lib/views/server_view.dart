import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/header/server_header.dart';
import 'package:server_express/components/server_item.dart';
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
        ServerHeader(title: "serverList".tr),
        Expanded(
          child: Obx(()=>
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
            ) : GridView.builder(
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