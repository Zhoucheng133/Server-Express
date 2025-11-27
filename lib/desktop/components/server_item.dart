import 'package:flutter/material.dart';
import 'package:server_express/getx/server_controller.dart';

class ServerItem extends StatefulWidget {
  final Server server;

  const ServerItem({super.key, required this.server});

  @override
  State<ServerItem> createState() => _ServerItemState();
}

class _ServerItemState extends State<ServerItem> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.server.addr
    );
  }
}