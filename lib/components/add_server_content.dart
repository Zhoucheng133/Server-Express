import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/add_server_item.dart';

class AddServerContent extends StatefulWidget {

  final TextEditingController nameController;
  final TextEditingController addrController;
  final TextEditingController portController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const AddServerContent({super.key, required this.nameController, required this.addrController, required this.portController, required this.usernameController, required this.passwordController});

  @override
  State<AddServerContent> createState() => _AddServerContentState();
}

class _AddServerContentState extends State<AddServerContent> {

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState)=>Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AddServerItem(label: "serverName".tr, controller: widget.nameController),
          const SizedBox(height: 10,),
          AddServerItem(label: "serverAddr".tr, controller: widget.addrController, hint: "ipDomain".tr, enableCorrect: false),
          const SizedBox(height: 10,),
          AddServerItem(label: "port".tr, controller: widget.portController, numberOnly: true, enableCorrect: false,),
          const SizedBox(height: 10,),
          AddServerItem(label: "username".tr, controller: widget.usernameController, enableCorrect: false),
          const SizedBox(height: 10,),
          AddServerItem(label: "password".tr, controller: widget.passwordController, obscureText: true, enableCorrect: false),
        ],
      )
    );
  }
}