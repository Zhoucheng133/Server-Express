import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/getx/ssh_controller.dart';

class TransferProgressView extends StatelessWidget {
  const TransferProgressView({super.key, required this.fallbackFileName});

  final String fallbackFileName;

  @override
  Widget build(BuildContext context) {
    final sshController = Get.find<SshController>();
    return Obx(() {
      final progress = sshController.transferProgress.value;
      final fileName = progress.currentFile.isEmpty
          ? fallbackFileName
          : progress.currentFile.split(RegExp(r'[/\\]')).last;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress.totalBytes == 0 ? null : progress.fraction,
          ),
          const SizedBox(height: 10),
          Text('$fileName  ${progress.percentage}%'),
          const SizedBox(height: 4),
          Text(progress.transferredLabel),
        ],
      );
    });
  }
}
