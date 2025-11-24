import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
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

class SshController extends GetxController {
  static String sshLoginHandler(String url, String port, String username, String password){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'lib/core.dylib' : 'lib/core.dll');
    final SSHLoginDart sshLogin=dynamicLib
    .lookup<NativeFunction<SSHLoginNative>>('SSHLogin')
    .asFunction();

    return sshLogin(url.toNativeUtf8(), port.toNativeUtf8(), username.toNativeUtf8(), password.toNativeUtf8()).toDartString();
  }

  static String sftpListHandler(String path){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'lib/core.dylib' : 'lib/core.dll');
    final SftpListDart sftpList=dynamicLib
    .lookup<NativeFunction<SftpListNative>>('SftpList')
    .asFunction();

    return sftpList(path.toNativeUtf8()).toDartString();
  }

  static String sftpDownloadHandler(String path, String local){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'lib/core.dylib' : 'lib/core.dll');
    final SftpDownloadDart sftpDownload=dynamicLib
    .lookup<NativeFunction<SftpDownloadNative>>('SftpDelete')
    .asFunction();

    return sftpDownload(path.toNativeUtf8(), local.toNativeUtf8()).toDartString();
  }

  static String sftpDeleteHandler(String path){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'lib/core.dylib' : 'lib/core.dll');
    final SftpDeleteDart sftpDelete=dynamicLib
    .lookup<NativeFunction<SftpDeleteNative>>('SftpDelete')
    .asFunction();

    return sftpDelete(path.toNativeUtf8()).toDartString();
  }

  static String sftpRenameHandler(String path, String newName){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'lib/core.dylib' : 'lib/core.dll');
    final SftpRenameNative sftpDownload=dynamicLib
    .lookup<NativeFunction<SftpRenameDart>>('SftpRename')
    .asFunction();

    return sftpDownload(path.toNativeUtf8(), newName.toNativeUtf8()).toDartString();
  }
}