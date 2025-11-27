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
        TitleBar(title: "serverList".tr),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              mainAxisExtent: 100
            ),
            itemBuilder: (context, index) {
              return Container(
                color: Colors.blue,
                child: Text('Item $index'),
              );
            },
            itemCount: 10,
          )
        )
      ],
    );
  }
}