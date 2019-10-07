// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:ffi' as ffi;
import 'save_file_dialog.dart';

// Example of using structs to pass strings to and from Dart/C
class Utf8 extends ffi.Struct<Utf8> {
  @ffi.Uint8()
  int char;

  static String fromUtf8(ffi.Pointer<Utf8> ptr) {
    final units = List<int>();
    var len = 0;
    while (true) {
      final char = ptr.elementAt(len++).load<Utf8>().char;
      if (char == 0) break;
      units.add(char);
    }
    return Utf8Decoder().convert(units);
  }

  static ffi.Pointer<Utf8> toUtf8(String s) {
    final units = Utf8Encoder().convert(s);
    final ptr = ffi.Pointer<Utf8>.allocate(count: units.length + 1);
    for (var i = 0; i < units.length; i++) {
      ptr.elementAt(i).load<Utf8>().char = units[i];
    }
    // Add the C string null terminator '\0'
    ptr.elementAt(units.length).load<Utf8>().char = 0;

    return ptr;
  }
}

// C string parameter pointer function - char *reverse(char *str, int length);
typedef file_dialog_func = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8> str, ffi.Int32 length);
typedef fileDialogFun = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8> str, int length);

class FileDialog {
  static const _path =
      '/home/weiminji/workspace/sources/flutter-projects/flutter-file-dialogs/filedialogs.so';
  static final _dylib = ffi.DynamicLibrary.open(_path);

  static String openSaveFileDialog(String newFile) {
    final _saveFileDialogPointer =
        _dylib.lookup<ffi.NativeFunction<file_dialog_func>>('saveFileDialog');
    final _saveFileDialog = _saveFileDialogPointer.asFunction<fileDialogFun>();

    final fileName =
        Utf8.fromUtf8(_saveFileDialog(Utf8.toUtf8(newFile), newFile.length));
    return fileName;
  }

  static String openSelectFolderDialog(String newFile) {
    final _selectFolderDialogPointer =
        _dylib.lookup<ffi.NativeFunction<file_dialog_func>>('selectFolderDialog');
    final _selectFolderDialog = _selectFolderDialogPointer.asFunction<fileDialogFun>();

    final fileName =
        Utf8.fromUtf8(_selectFolderDialog(Utf8.toUtf8(newFile), newFile.length));
    return fileName;
  }
}
