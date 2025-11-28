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

class SshController extends GetxController {
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

  static String sftpDownloadHandler(String path, String local){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final SftpDownloadDart sftpDownload=dynamicLib
    .lookup<NativeFunction<SftpDownloadNative>>('SftpDelete')
    .asFunction();

    return sftpDownload(path.toNativeUtf8(), local.toNativeUtf8()).toDartString();
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
    final SftpRenameNative sftpDownload=dynamicLib
    .lookup<NativeFunction<SftpRenameDart>>('SftpRename')
    .asFunction();

    return sftpDownload(path.toNativeUtf8(), newName.toNativeUtf8()).toDartString();
  }

  static String disconnectHandler(List params){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final DisconnectNative disconnect=dynamicLib
    .lookup<NativeFunction<DisconnectDart>>('Disconnect')
    .asFunction();

    return disconnect().toDartString();
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
}