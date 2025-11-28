import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_express/getx/server_controller.dart';

class ServerItem extends StatefulWidget {
  final Server server;

  const ServerItem({super.key, required this.server});

  @override
  State<ServerItem> createState() => _ServerItemState();
}

class _ServerItemState extends State<ServerItem> {

  bool hover=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_)=>setState(() {
          hover=true;
        }),
        onExit: (_)=>setState(() {
          hover=false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
            border: hover ? Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ) : Border.all(
              color: Theme.of(context).colorScheme.secondaryContainer,
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.dns_rounded),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(
                        widget.server.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 16
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      tooltip: "actions".tr,
                      onSelected: (value) {
                        // TODO 操作
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          height: 35,
                          value: "edit",
                          child: Text('edit'.tr),
                        ),
                        PopupMenuItem(
                          height: 35,
                          value: "del",
                          child: Text('delete'.tr),
                        ),
                      ],
                      child: Icon(Icons.more_vert_rounded),
                    )
                  ],
                ),
                const SizedBox(height: 5,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${widget.server.username}@",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.server.addr,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}