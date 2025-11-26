import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/getx/ssh_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Server {
  String id;
  String name;
  String url;
  String username;
  String password;
  String port;

  Server({required this.id, required this.name, required this.url, required this.port, required this.username, required this.password});

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'],
      name: json['name'],
      url: json["url"],
      port: json["port"],
      username: json['username'],
      password: json["password"]
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "url": url,
      "port": port,
      "username": username,
      "password": password
    };
  }
}

class ServerController extends GetxController {
  RxList servers=<Server>[].obs;
  Rx<Server?> nowServer=null.obs;

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();
  }

  ServerController(){
    init();
  }

  Future<void> saveServers() async {
    prefs.setString("servers", jsonEncode(
      servers.map((item)=>item.toJson()).toList()
    ));
  }

  void addServer(Server server){
    servers.add(server);
    saveServers();
  }

  void removeServer(String id){
    servers.removeWhere((item)=>item.id==id);
    saveServers();
  }

  Future<void> initServers() async {
    final servers=prefs.getString("servers");
    if(servers==null || servers.isEmpty){
      return;
    }
  }

  Future<void> serverCheck(BuildContext context, String addr, String port, String username, String password) async {
    final SshController sshController=Get.find();
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: CircularProgressIndicator()
          ),
        ),
      ),
    );
    final message=await sshController.sshLogin(addr, port, username, password);
    if(context.mounted) Navigator.pop(context);
    if(context.mounted && message.contains("OK")) Navigator.pop(context);
    if(context.mounted){
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text(message.contains("OK") ? "addSuccess".tr : "addFail".tr),
          content: Text(message),
          actions: [
            if(message.contains("OK")) TextButton(
              onPressed: (){
                // TODO 直接连接
              }, 
              child: Text("connect".tr)
            ),
            ElevatedButton(
              onPressed: () async {
                if(message.contains("OK")){
                  await sshController.disconnect(); 
                }
                if(context.mounted) Navigator.pop(context);
              }, 
              child: Text("ok".tr)
            )
          ],
        )
      );
    }
  }
}