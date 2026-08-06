import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadView extends StatefulWidget {
  const DownloadView({super.key});

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('download'.tr),
      ),
    );
  }
}