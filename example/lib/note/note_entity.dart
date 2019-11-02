import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NoteStatusChangedNotifier extends ValueNotifier<Null> {
  NoteStatusChangedNotifier() : super(null);

  void notifyAll() {
    notifyListeners();
  }
}

class NoteEntity {
  String name;
  NoteEntity parent;
  FileSystemEntity entity;

  bool onSelected = false;
  NoteStatusChangedNotifier statusChangedNotifier = new NoteStatusChangedNotifier();

  NoteEntity(this.entity, this.parent) {
    _setName();
  }

  @override
  int get hashCode {
    return name.hashCode + entity.hashCode;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! NoteEntity) 
      return false;

    final note = other;
    return entity.path == note.entity.path;
  }

  void _setName() {
    name = basename(entity.path);
    name = name.split('.')[0];
  }

  void rename(String newFileName) {
    if (newFileName == name)
      return;

    final newFilePath = '${entity.parent.path}/$newFileName';
    entity = entity.renameSync(newFilePath);
    _setName();

    statusChangedNotifier.notifyAll();
  }
}

class NoteSelectedNotifier extends ValueNotifier<NoteEntity> {
  NoteSelectedNotifier(value) : super(value);
}
