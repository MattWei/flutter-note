import 'dart:io';

import 'note_entity.dart';
class Note extends NoteEntity {
  Note(FileSystemEntity entity, NoteEntity parent) : super(entity, parent);

  @override
  void rename(String newFileName) {
    if (newFileName == name)
      return;

    newFileName += '.md';
    super.rename(newFileName);
  }

  void saveContent(String content) {
    final File file = entity;
    file.writeAsStringSync(content);
  }

}