import 'package:flutter/material.dart';
import 'package:server_express/components/header/server_buttons.dart';

class ServerHeader extends StatefulWidget {

  final String title;

  const ServerHeader({super.key, required this.title});

  @override
  State<ServerHeader> createState() => _ServerHeaderState();
}

class _ServerHeaderState extends State<ServerHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            Expanded(
              child: Container(),
            ),
            ServerButtons()
          ],
        ),
        Divider(
          thickness: 2,
        )
      ],
    );
  }
}