import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/add_server/add_server_item.dart';

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
  late final FocusNode nameFocus;
  late final FocusNode addrFocus;
  late final FocusNode portFocus;
  late final FocusNode usernameFocus;
  late final FocusNode passwordFocus;

  @override
  void initState() {
    super.initState();
    nameFocus = FocusNode();
    addrFocus = FocusNode();
    portFocus = FocusNode();
    usernameFocus = FocusNode();
    passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    nameFocus.dispose();
    addrFocus.dispose();
    portFocus.dispose();
    usernameFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState)=>SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AddServerItem(
              label: "serverName".tr, 
              controller: widget.nameController,
              focusNode: nameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => addrFocus.requestFocus(),
            ),
            const SizedBox(height: 10,),
            AddServerItem(
              label: "serverAddr".tr, 
              controller: widget.addrController, 
              hint: "ipDomain".tr, 
              enableCorrect: false,
              focusNode: addrFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => portFocus.requestFocus(),
            ),
            const SizedBox(height: 10,),
            AddServerItem(
              label: "port".tr, 
              controller: widget.portController, 
              numberOnly: true, 
              enableCorrect: false,
              focusNode: portFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => usernameFocus.requestFocus(),
            ),
            const SizedBox(height: 10,),
            AddServerItem(
              label: "username".tr, 
              controller: widget.usernameController, 
              enableCorrect: false,
              focusNode: usernameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 10,),
            AddServerItem(
              label: "password".tr, 
              controller: widget.passwordController, 
              obscureText: true, 
              enableCorrect: false,
              focusNode: passwordFocus,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => passwordFocus.unfocus(),
            ),
          ],
        ),
      )
    );
  }
}