import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_express/desktop/components/header/file_buttons.dart';
import 'package:server_express/getx/file_controller.dart';
import 'package:server_express/getx/server_controller.dart';

class FileHeader extends StatefulWidget {
  const FileHeader({super.key});

  @override
  State<FileHeader> createState() => _FileHeaderState();
}

class _FileHeaderState extends State<FileHeader> {

  final FileController fileController=Get.find();
  final ServerController serverController=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              serverController.nowServer.value==null ? '' : serverController.nowServer.value!.name,
              style: GoogleFonts.notoSansSc(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            Expanded(
              child: Container(),
            ),
            FileButtons()
          ],
        ),
        Divider(
          thickness: 2,
        )
      ],
    );
  }
}