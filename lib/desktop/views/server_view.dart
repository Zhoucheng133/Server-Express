import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/desktop/components/header.dart';

class ServerView extends StatefulWidget {
  const ServerView({super.key});

  @override
  State<ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DesktopTitleBar(title: "serverList".tr),
        Expanded(child: Container())
      ],
    );
  }
}