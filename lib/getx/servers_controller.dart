import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Server {
  String id;
  String url;
  String username;
  String password;

  Server({required this.id, required this.url, required this.username, required this.password});

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'],
      url: json["url"],
      username: json['username'],
      password: json["password"]
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "url": url,
      "username": username,
      "password": password
    };
  }
}

class ServersController extends GetxController {
  RxList servers=<Server>[].obs;

  Future<void> saveServers() async {
    final prefs=await SharedPreferences.getInstance();
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
}