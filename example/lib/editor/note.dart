import 'package:flutter/material.dart';

import '../note/note.dart';
import '../note/note_entity.dart';

import 'editor_mode.dart';
import 'note_editer.dart';
import 'note_title.dart';
import 'note_toolsbar.dart';
import 'note_viewer.dart';

import 'zefyr_note_editor.dart';

class NoteRoute extends StatefulWidget {
  NoteRoute({Key key, @required this.noteChangedNotifier}) : super(key: key);

  final NoteSelectedNotifier noteChangedNotifier;

  @override
  _NoteRouteState createState() => _NoteRouteState();
}

class _NoteRouteState extends State<NoteRoute> {
  final EditorSwitchedNotifier _editorSwitchedNotifier =
      new EditorSwitchedNotifier(EditorMode.view);
  ZefyrNoteEditor _editor;
  final _titleController = TextEditingController();
  final NoteChangedNotifier _noteChangedNotifier = NoteChangedNotifier(null);

  @override
  initState() {
    super.initState();
    widget.noteChangedNotifier.addListener(_handleNoteChanged);
    _editorSwitchedNotifier.addListener(_handleEditerModeChanged);
  }

  void _saveNoteToEntity() {
    final note = _noteChangedNotifier.value;
    final title = _titleController.value.text;
    if (title != note.name) {
      print('rename ${note.name} to $title');
      note.rename(title);
    }

    if (_editor.isChanged) {
      note.saveContent(_editor.getContent());
    }
  }

  void _handleEditerModeChanged() {
    final editorMode = _editorSwitchedNotifier.value;

    if (editorMode == EditorMode.view) {
      _saveNoteToEntity();
    }

    setState(() {});
  }

  Widget _showNote() {
    final editorMode = _editorSwitchedNotifier.value;
    final note = _noteChangedNotifier.value;
    Widget noteWidget;
    if (note == null) {
      noteWidget = Container();
    } else if (editorMode == EditorMode.edit) {
      _editor ??= ZefyrNoteEditor();
      _editor.note = note;

      noteWidget = NoteEditerRoute(
        noteEntity: note,
        editor: _editor,
      );
    } else {
      noteWidget = NoteViewerRoute(
        noteEntity: note,
      );
    }
    return Expanded(
      flex: 1,
      child: noteWidget,
    );
  }

  Widget _showTitleBar() {
    return new Container(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: NoteTitleRoute(
              editorSwitchedNotifier: _editorSwitchedNotifier,
              noteChangedNotifier: _noteChangedNotifier,
              titleController: _titleController,
            ),
          ),
          TitleToolsBarRoute(
            editorSwitchedNotifier: _editorSwitchedNotifier,
            noteStatusChangedNotifier: _noteChangedNotifier,
            titleController: _titleController,
          ),
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
    final currentNote = _noteChangedNotifier.value;
    final Note newNote = widget.noteChangedNotifier.value;

    if (currentNote != null) {
      if (currentNote == newNote) {
        return;
      }

      final editorMode = _editorSwitchedNotifier.value;
      if (editorMode == EditorMode.edit) {
        if (_titleController.value.text != currentNote.name ||
            _editor.isChanged) {
          _saveNoteToEntity();
        }

        _editorSwitchedNotifier.value = EditorMode.view;
      }
    }

    _noteChangedNotifier.value = widget.noteChangedNotifier.value;
    setState(() {
    });
  }
}
