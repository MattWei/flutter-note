import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

enum NoteStatusType {RESET, EXTEND, RENAME, ADD_ITEM, REMOVE_ITEM, BEFORE_REMOVE_ITEM}

class NoteStatusChangedNotifier extends ValueNotifier<NoteStatusType> {
  NoteStatusChangedNotifier() : super(NoteStatusType.RESET);
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

    statusChangedNotifier.value = NoteStatusType.RENAME;
  }

  void deleteSubitem(NoteEntity subEntity) {
    
  }

  void move(NoteEntity newParen) {
    parent.statusChangedNotifier.value = NoteStatusType.BEFORE_REMOVE_ITEM;
    parent.deleteSubitem(this);
    final file = basename(entity.path);
    final newFilePath = '${newParen.entity.path}/$file';
    entity = entity.renameSync(newFilePath);
    parent.statusChangedNotifier.value = NoteStatusType.REMOVE_ITEM;
    parent = newParen;
  }
}

class NoteSelectedNotifier extends ValueNotifier<NoteEntity> {
  NoteSelectedNotifier(value) : super(value);
}

class DragTargetNotifier extends ValueNotifier<bool> {
  DragTargetNotifier() : super(false);
}