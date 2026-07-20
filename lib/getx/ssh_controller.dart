import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// func SSHLogin(url *C.char, port *C.char, username *C.char, password *C.char) *C.char 
typedef SSHLoginNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);
typedef SSHLoginDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);

// func SftpList(path *C.char) *C.char 
typedef SftpListNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef SftpListDart = Pointer<Utf8> Function(Pointer<Utf8>);

// func SftpDownload(path *C.char, local *C.char) *C.char 
typedef SftpDownloadNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef SftpDownloadDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

// func SftpDelete(path *C.char) *C.char 
typedef SftpDeleteNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef SftpDeleteDart = Pointer<Utf8> Function(Pointer<Utf8>);

// func SftpRename(path *C.char, newName *C.char) *C.char 
typedef SftpRenameNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef SftpRenameDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

// func Disconnect() *C.char
typedef DisconnectNative = Pointer<Utf8> Function();
typedef DisconnectDart = Pointer<Utf8> Function();

// func SftpUpload(path *C.char, local *C.char) *C.char
typedef SftpUploadNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef SftpUploadDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

// func SftpMkdir(path *C.char, name *C.char) *C.char
typedef SftpMkdirNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef SftpMkdirDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

// func SftpCancel() *C.char
typedef SftpCancelNative = Pointer<Utf8> Function();
typedef SftpCancelDart = Pointer<Utf8> Function();

// func SftpTransferProgress() *C.char
typedef SftpTransferProgressNative = Pointer<Utf8> Function();
typedef SftpTransferProgressDart = Pointer<Utf8> Function();
typedef FreeStringNative = Void Function(Pointer<Utf8>);
typedef FreeStringDart = void Function(Pointer<Utf8>);

class TransferProgress {
  final bool active;
  final int totalBytes;
  final int transferredBytes;
  final String currentFile;
  final int currentFileBytes;
  final int currentFileTotalBytes;

  const TransferProgress({
    required this.active,
    required this.totalBytes,
    required this.transferredBytes,
    required this.currentFile,
    required this.currentFileBytes,
    required this.currentFileTotalBytes,
  });

  factory TransferProgress.empty() => const TransferProgress(
    active: false,
    totalBytes: 0,
    transferredBytes: 0,
    currentFile: '',
    currentFileBytes: 0,
    currentFileTotalBytes: 0,
  );

  factory TransferProgress.fromJson(Map<String, dynamic> json) =>
      TransferProgress(
        active: json['active'] == true,
        totalBytes: (json['total_bytes'] as num? ?? 0).toInt(),
        transferredBytes: (json['transferred_bytes'] as num? ?? 0).toInt(),
        currentFile: json['current_file'] as String? ?? '',
        currentFileBytes: (json['current_file_bytes'] as num? ?? 0).toInt(),
        currentFileTotalBytes: (json['current_file_total_bytes'] as num? ?? 0)
            .toInt(),
      );

  double get fraction => totalBytes == 0
      ? 0
      : (transferredBytes / totalBytes).clamp(0, 1).toDouble();
  int get percentage => (fraction * 100).round();
  String get transferredLabel =>
      '${_formatBytes(transferredBytes)} / ${_formatBytes(totalBytes)}';

  static String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }
}

class SshController extends GetxController {
  final transferProgress = TransferProgress.empty().obs;
  Timer? _progressTimer;
  static String sshLoginHandler(List params){
    String url=params[0];
    String port=params[1];
    String username=params[2];
    String password=params[3];
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SSHLoginDart sshLogin=dynamicLib
    .lookup<NativeFunction<SSHLoginNative>>('SSHLogin')
    .asFunction();

    return sshLogin(url.toNativeUtf8(), port.toNativeUtf8(), username.toNativeUtf8(), password.toNativeUtf8()).toDartString();
  }

  static String sftpListHandler(String path){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpListDart sftpList=dynamicLib
    .lookup<NativeFunction<SftpListNative>>('SftpList')
    .asFunction();

    return sftpList(path.toNativeUtf8()).toDartString();
  }

  static String sftpDownloadHandler(List params){
    String path=params[0];
    String local=params[1];
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpDownloadDart sftpDownload=dynamicLib
    .lookup<NativeFunction<SftpDownloadNative>>('SftpDownload')
    .asFunction();

    return sftpDownload(path.toNativeUtf8(), local.toNativeUtf8()).toDartString();
  }

  static String transferProgressHandler(List params) {
    final dynamicLib = DynamicLibrary.open(
      Platform.isMacOS ? 'core.dylib' : 'core.dll',
    );
    final SftpTransferProgressDart getProgress = dynamicLib
        .lookup<NativeFunction<SftpTransferProgressNative>>(
          'SftpTransferProgress',
        )
        .asFunction();
    final FreeStringDart freeString = dynamicLib
        .lookup<NativeFunction<FreeStringNative>>('FreeString')
        .asFunction();
    final result = getProgress();
    try {
      return result.toDartString();
    } finally {
      freeString(result);
    }
  }

  static String sftpDeleteHandler(String path){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpDeleteDart sftpDelete=dynamicLib
    .lookup<NativeFunction<SftpDeleteNative>>('SftpDelete')
    .asFunction();

    return sftpDelete(path.toNativeUtf8()).toDartString();
  }

  static String sftpRenameHandler(List params){
    String path=params[0]; 
    String newName=params[1];
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpRenameDart sftpDownload=dynamicLib
    .lookup<NativeFunction<SftpRenameDart>>('SftpRename')
    .asFunction();

    return sftpDownload(path.toNativeUtf8(), newName.toNativeUtf8()).toDartString();
  }

  static String uploadHandler(List params){
    String path=params[0]; 
    String local=params[1];

    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpUploadDart sftpUpload=dynamicLib
    .lookup<NativeFunction<SftpUploadDart>>('SftpUpload')
    .asFunction();

    return sftpUpload(path.toNativeUtf8(), local.toNativeUtf8()).toDartString();
  }

  static String mkdirHandler(List params){
    String path=params[0];
    String name=params[1];
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpMkdirDart sftpMkdir=dynamicLib
    .lookup<NativeFunction<SftpMkdirNative>>('SftpMkdir')
    .asFunction();

    return sftpMkdir(path.toNativeUtf8(), name.toNativeUtf8()).toDartString();
  }

  static String disconnectHandler(List params){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final DisconnectDart disconnect=dynamicLib
    .lookup<NativeFunction<DisconnectDart>>('Disconnect')
    .asFunction();

    return disconnect().toDartString();
  }

  static String cancelTransferHandler(List params){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpCancelDart cancel=dynamicLib
    .lookup<NativeFunction<SftpCancelNative>>('SftpCancel')
    .asFunction();

    return cancel().toDartString();
  }

  Future<String> sshLogin(String url, String port, String username, String password) async {
    return await compute(sshLoginHandler, [url, port, username, password]);
  }

  Future<String> disconnect() async {
    return await compute(disconnectHandler, []);
  }

  Future<String> sftpList(String path) async {
    return await compute(sftpListHandler, path);
  }

  Future<String> sftpDownload(String path, String local) async {
    return _runTransfer(() => compute(sftpDownloadHandler, [path, local]));
  }

  Future<String> sftpDelete(String path) async {
    return await compute(sftpDeleteHandler, path);
  }

  Future<String> sftpRename(String path, String newName) async {
    return await compute(sftpRenameHandler, [path, newName]);
  }

  Future<String> sftpUpload(String path, String local) async {
    return _runTransfer(() => compute(uploadHandler, [path, local]));
  }

  Future<String> sftpMkdir(String path, String name) async {
    return await compute(mkdirHandler, [path, name]);
  }

  Future<String> cancelTransfer() async {
    _progressTimer?.cancel();
    _progressTimer = null;
    return await compute(cancelTransferHandler, []);
  }

  Future<void> _refreshTransferProgress() async {
    try {
      final response = await compute(transferProgressHandler, []);
      transferProgress.value = TransferProgress.fromJson(jsonDecode(response));
    } catch (_) {}
  }

  Future<String> _runTransfer(Future<String> Function() operation) async {
    transferProgress.value = TransferProgress.empty();
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _refreshTransferProgress();
    });
    try {
      return await operation();
    } finally {
      _progressTimer?.cancel();
      _progressTimer = null;
      await _refreshTransferProgress();
    }
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }
}