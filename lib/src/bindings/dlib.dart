import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import '../util/constant.dart';

const Set<String> _supported = {'linux', 'mac', 'win'};

String get binaryName {
  String os, ext;
  if (Platform.isLinux) {
    os = 'linux';
    ext = 'so';
  } else if (Platform.isMacOS) {
    os = 'mac';
    ext = 'so';
  } else if (Platform.isWindows) {
    os = 'win';
    ext = 'dll';
  } else {
    throw Exception('Unsupported platform!');
  }

  if (!_supported.contains(os)) {
    throw UnsupportedError('Unsupported platform: $os!');
  }

  return 'libtensorflowlite_c-$os.$ext';
}

/// TensorFlowLite C library.
// ignore: missing_return
DynamicLibrary tflitelib = () {
  if (Platform.isAndroid) {
    try {
      print('kienmtTest load dynamic');
      return DynamicLibrary.open('libtensorflowlite_c.so');
    } catch (_) {
      try {
        var libDir = ConsTfLite.myLibDir;
        print(ConsTfLite.getMyLibDir + 'kienmtTest aaa');
        print('kienmtTest libdir $libDir');
        if (libDir.contains('libtensorflowlite_c.so'))
          return DynamicLibrary.open('$libDir');
        else
          return DynamicLibrary.open('$libDir/libtensorflowlite_c.so');
      } catch (_) {
        print('kienmtTest load dynamic with data');
        final appIdAsBytes = File('/proc/self/cmdline').readAsBytesSync();
        // app id ends with the first \0 character in here.
        final endOfAppId = max(appIdAsBytes.indexOf(0), 0);
        final appId = String.fromCharCodes(appIdAsBytes.sublist(0, endOfAppId));
        print('kienmtTest appId $appId');
        return DynamicLibrary.open(
            '/data/data/$appId/lib/libtensorflowlite_c.so');
      }
    }
  } else if (Platform.isIOS) {
    return DynamicLibrary.process();
  } else {
    return DynamicLibrary.open(
        Directory(Platform.resolvedExecutable).parent.path +
            '/blobs/${binaryName}');
  }
}();

Future<String> asyncMethod(MethodChannel _channel) async {
  final String result = await _channel.invokeMethod('getNativeLibraryDir');
  return result;
}
