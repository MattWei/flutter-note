import 'dart:io';

import 'note.dart';
import 'note_entity.dart';

class Notebook extends NoteEntity {
  Notebook(FileSystemEntity entity, this.isRoot, Notebook parent)
      : super(entity, parent) {
    if (isRoot) {
      expanded = true;
    }
    if (parent != null) {
      parent.dragTargetNotifier.addListener(_onParentIsDragTarget);
    }
  }

  bool isRoot = false;
  bool expanded = false;
  DragTargetNotifier dragTargetNotifier = new DragTargetNotifier();

  List<NoteEntity> subNotes = [];

  bool _isOnAccepting = false;

  void _onParentIsDragTarget() {
    final Notebook parentNotebook = parent;
    final parentOnTarget = parentNotebook.dragTargetNotifier.value;
    final isOnTarget = dragTargetNotifier.value;
    if (parentOnTarget == isOnTarget) {
      return;
    }

    if (parentOnTarget && !isOnTarget) {
      dragTargetNotifier.value = true;
    }

    if (!parentOnTarget && isOnTarget) {
      if (!_isOnAccepting) {
        dragTargetNotifier.value = false;
      }
    }
  }

  set onDragItems(bool value) {
    final isOnTarget = dragTargetNotifier.value;
    if (isOnTarget != value) {
      dragTargetNotifier.value = value;
    }
  }

  bool get onDragItems {
    return dragTargetNotifier.value;
  }

  @override
  void rename(String newFileName) {
    subNotes.clear();
    super.rename(newFileName);
  }

  bool contain(FileSystemEntity entity) {
    if (subNotes.isEmpty) return false;

    for (var subNote in subNotes) {
      if (subNote.entity.path == entity.path) return true;
    }

    return false;
  }

  NoteEntity find(FileSystemEntity entity) {
    if (subNotes.isEmpty) return null;

    for (var subNote in subNotes) {
      if (subNote.entity.path == entity.path) return subNote;
    }

    return null;
  }

  String createSubnotebook(String entityName) {
    final newFolderPath = '${entity.path}/$entityName';
    final newFolder = new Directory(newFolderPath);
    if (contain(newFolder)) {
      return 'Have same name note or notebook';
    }
    newFolder.createSync(recursive: true);

    print('create new folder $newFolderPath');
    final notebook = new Notebook(newFolder, false, this);
    subNotes.add(notebook);
    statusChangedNotifier.value = NoteStatusType.ADD_ITEM;

    return 'OK';
  }

  String createSubnote(String entityName) {
    final newNotePath = '${entity.path}/$entityName.md';
    final newNoteFile = new File(newNotePath);
    if (contain(newNoteFile)) {
      return 'Have same name note or notebook';
    }

    newNoteFile.createSync(recursive: true);
    final newNote = Note(newNoteFile, this);
    subNotes.add(newNote);
    statusChangedNotifier.value = NoteStatusType.ADD_ITEM;

    return 'OK';
  }

  void _addSubnoteEntity(FileSystemEntity entity) {
    var noteEntity = find(entity);
    if (noteEntity == null) {
      if (entity is File) {
        noteEntity = new Note(entity, this);
      } else {
        noteEntity = new Notebook(entity, false, this);
      }
      subNotes.add(noteEntity);
    }
  }

  bool _noteIsExist(NoteEntity note, List<FileSystemEntity> entities) {
    for (var entity in entities) {
      if (entity.path == note.entity.path) {
        return true;
      }
    }

    return false;
  }

  void updateSubNotes(List<FileSystemEntity> entities) {
    for (var noteEntity in subNotes) {
      if (!_noteIsExist(noteEntity, entities)) {
        subNotes.remove(noteEntity);
      }
    }

    for (var entity in entities) {
      _addSubnoteEntity(entity);
    }
  }

  void onSelect() {
    expanded = !expanded;
    onSelected = true;
  }

  @override
  void deleteSubitem(NoteEntity subEntity) {
    if (subNotes.contains(subEntity)) {
      subNotes.remove(subEntity);
    }
  }
}
