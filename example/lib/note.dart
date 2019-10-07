import 'dart:io';

import 'note_editer.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'note_viewer.dart';
import 'save_file_dialog.dart';

class NoteChangedNotifier extends ValueNotifier<FileSystemEntity> {
  NoteChangedNotifier(value) : super(value);
}

class NoteRoute extends StatefulWidget {
  NoteRoute({Key key, @required this.noteChangedNotifier}) : super(key: key);

  final NoteChangedNotifier noteChangedNotifier;

  @override
  _NoteRouteState createState() => _NoteRouteState();
}

enum NoteMode { create, edit, view }

class _NoteRouteState extends State<NoteRoute> {
  FileSystemEntity _noteEntity;
  NoteMode _noteMode = NoteMode.create;
  final _titleController = TextEditingController();
  final NoteSavedNotifier _noteSaveNotifier = NoteSavedNotifier(null);

  String _title;

  @override
  initState() {
    super.initState();
    widget.noteChangedNotifier.addListener(_handleNoteChanged);

    _noteEntity = widget.noteChangedNotifier.value;

    if (_noteEntity != null) {
      _setTitleText();
      _noteMode = NoteMode.view;
    } else {
      _noteMode = NoteMode.create;
    }
  }

  String _getTitleFromFileEntity() {
    if (_noteEntity == null) 
      return '';

    _title = basename(_noteEntity.path);
    _title = _title.split('.')[0];

    return _title;
  }

  void _setTitleText() {
    _titleController.value = _titleController.value.copyWith(
      text: _getTitleFromFileEntity(),
      selection:
          TextSelection(baseOffset: _title.length, extentOffset: _title.length),
      composing: TextRange.empty,
    );
  }

  Widget _showNote() {
    Widget noteWidget;
    if (_noteMode == NoteMode.create) {
      noteWidget = Container();
    } else if (_noteMode == NoteMode.edit) {
      noteWidget = NoteEditerRoute(
        noteEntity: _noteEntity,
        noteSaveNotifier: _noteSaveNotifier,
      );
    } else {
      noteWidget = NoteViewerRoute(
        noteEntity: _noteEntity,
      );
    }

    return Expanded(
      flex: 1,
      child: noteWidget,
    );
  }

  Widget _showTitle() {
    return Expanded(
      flex: 1,
      child: new TextField(
        controller: _titleController,
        style: TextStyle(fontFamily: 'NotoSerif'),
        readOnly: _noteMode == NoteMode.view,
      ),
    );
  }

  Widget _createToolsbar() {
    var button = '';
    if (_noteMode == NoteMode.create) {
      button = 'Create';
    } else if (_noteMode == NoteMode.edit) {
      button = 'Save';
    } else if (_noteMode == NoteMode.view) {
      button = 'Edit';
    }

    return new Text(button);
  }

  String _getTitleFromTitleBar() {
    final title = _titleController.text;
    if (title.isEmpty) {
      return '';
    }

    return title;
  }

  void _createNewNote() {
    var title = _getTitleFromTitleBar();
    if (title.isEmpty) return;

    title += '.md';
    final filePath = FileDialog.openSaveFileDialog(title);
    if (filePath != null && filePath.isNotEmpty) {
      final newFile = new File(filePath);
      newFile.createSync(recursive: true);
      _noteEntity = newFile;
      widget.noteChangedNotifier.value = _noteEntity;
      
      print('create new note $filePath');
      setState(() {
        _setTitleText();
        _noteMode = NoteMode.edit;
      });
    }
  }

  void _renameNote(String newFileName) {
    final File oldFile = _noteEntity;
    final newFilePath = '${oldFile.parent.path}/$newFileName.md';
    _noteEntity = oldFile.renameSync(newFilePath);

    widget.noteChangedNotifier.value = _noteEntity;
  }

  void _saveNote() {
    print('save note');

    final title = _getTitleFromTitleBar();
    if (title.isEmpty) return;

    if (title != _getTitleFromFileEntity()) {
      _renameNote(title);
    }

    print('new note title $title');
    _noteSaveNotifier.saveTo(_noteEntity);
    _noteMode = NoteMode.view;
    setState(() {});
  }

  void _toolsBarOnPress() {
    print('toolsBarOnPress');
    if (_noteMode == NoteMode.create) {
      _createNewNote();
    } else if (_noteMode == NoteMode.edit) {
      _saveNote();
    } else if (_noteMode == NoteMode.view) {
      _noteMode = NoteMode.edit;
      setState(() {});
    }
  }

  Widget _showTools() {
    return new RaisedButton(
      child: _createToolsbar(),
      onPressed: _toolsBarOnPress,
    );
  }

  Widget _showTitleBar() {
    return new Container(
      height: 50,
      child: Row(
        children: <Widget>[
          _showTitle(),
          _showTools(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          _showTitleBar(),
          _showNote(),
        ],
      ),
    );
  }

  void _handleNoteChanged() {
    setState(() {
      _noteEntity = widget.noteChangedNotifier.value;
      if (_noteEntity != null) {
        _noteMode = NoteMode.view;
      } else {
        _noteMode = NoteMode.create;
      }

      _setTitleText();
    });
  }
}
