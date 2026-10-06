import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/general.dart';

class EditView extends StatefulWidget {
  final String filePath;

  const EditView({super.key, required this.filePath});

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final TextEditingController controller=TextEditingController();
  bool loading=true;
  bool saving=false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadFile();
  }

  Future<void> loadFile() async {
    try {
      controller.text=await File(widget.filePath).readAsString();
    } catch (_) {
      error='openFailed'.tr;
    }
    if(mounted){
      setState(() {
        loading=false;
      });
    }
  }

  Future<void> saveFile() async {
    if(saving || loading) return;
    setState(() {
      saving=true;
    });
    try {
      await File(widget.filePath).writeAsString(controller.text);
      if(mounted) Navigator.of(context).pop();
    } catch (_) {
      if(mounted){
        showGeneralOk(context, "saveFailed".tr, "tryAgainTip".tr);
      }
    } finally {
      if(mounted){
        setState(() {
          saving=false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filePath.split(Platform.pathSeparator).last),
        actions: [
          IconButton(
            onPressed: saving || loading ? null : saveFile,
            icon: const Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) : error!=null ? Center(child: Text(error!)) : Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          expands: true,
          maxLines: null,
          minLines: null,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
