import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/getx/ssh_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Server {
  String id;
  String name;
  String addr;
  String username;
  String password;
  String port;

  Server({required this.id, required this.name, required this.addr, required this.port, required this.username, required this.password});

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'],
      name: json['name'],
      addr: json["addr"],
      port: json["port"],
      username: json['username'],
      password: json["password"]
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "addr": addr,
      "port": port,
      "username": username,
      "password": password
    };
  }
}

class ServerController extends GetxController {
  RxList servers=<Server>[].obs;
  Rx<Server?> nowServer=Rx<Server?>(null);

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();
    initServers();
  }

  ServerController(){
    init();
  }

  Future<void> saveServers() async {
    prefs.setString("servers", jsonEncode(
      servers.map((item)=>item.toJson()).toList()
    ));
  }

  void removeServer(String id){
    servers.removeWhere((item)=>item.id==id);
    saveServers();
  }

  Future<void> addServer(BuildContext context, String name, String addr, String port, String username, String password) async {
    final SshController sshController=Get.find();
    String message=await serverCheck(context, addr, port, username, password);
    if(message.contains("OK") && context.mounted){

      Server thisServer=Server(
        id: Uuid().v4(), 
        name: name, 
        addr: addr, 
        port: port, 
        username: username, 
        password: password
      );
      servers.add(thisServer);
      saveServers();

      Navigator.pop(context);
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text("addSuccess".tr),
          content: Text(message),
          actions: [
            if(message.contains("OK")) TextButton(
              onPressed: (){
                nowServer.value=thisServer;
              }, 
              child: Text("connect".tr)
            ),
            ElevatedButton(
              onPressed: () async {
                await sshController.disconnect();
                if(context.mounted) Navigator.pop(context);
              }, 
              child: Text("ok".tr)
            )
          ],
        )
      );
    }else if(context.mounted){
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text("addFail".tr),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: ()=> Navigator.pop(context), 
              child: Text("ok".tr)
            )
          ],
        )
      );
    }
  }

  Future<void> editServer(BuildContext context, Server server) async {
    int index = servers.indexWhere((s) => s.id == server.id);
    if (index == -1) return;
    servers[index] = server;
    saveServers();
    Navigator.pop(context);
  }

  Future<void> initServers() async {
    final prefsData=prefs.getString("servers");
    if(prefsData==null || prefsData.isEmpty){
      return;
    }

    try {
      final List<dynamic> json = jsonDecode(prefsData) as List;
      servers.value=json.map((item)=>Server.fromJson(item)).toList();
    } catch (_) {}
  }

  Future<String> serverCheck(BuildContext context, String addr, String port, String username, String password) async {
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
    return message;
  }
}