import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;

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
  const MethodChannel _channel = MethodChannel('tflite_flutter_plugin');
  String libDir = asyncMethod(_channel);
  print('kienmtTest load dynamic with libdir');
  var lib = libDir;
  print('kienmtTest libdir $lib');
  if (Platform.isAndroid) {
    try {
      print('kienmtTest load dynamic');
      return DynamicLibrary.open('libtensorflowlite_c.so');
    } catch (_) {
      try {
        const MethodChannel _channel = MethodChannel('tflite_flutter_plugin');
        String libDir = asyncMethod(_channel);
        print('kienmtTest load dynamic with libdir');
        var lib = libDir;
        print('kienmtTest libdir $lib');
        return DynamicLibrary.open('$lib/libtensorflowlite_c.so');
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

dynamic asyncMethod(MethodChannel _channel) async {
  final result = await _channel.invokeMethod('getNativeLibraryDir');
  return result;
}

