import 'package:flutter/material.dart';

import '../note/note.dart';
import 'zefyr_note_editor.dart';

class NoteEditerRoute extends StatefulWidget {
  NoteEditerRoute(
      {Key key, @required this.noteEntity, @required this.editor})
      : super(key: key);

  final Note noteEntity;
  final ZefyrNoteEditor editor;

  @override
  _NoteEditerRouteState createState() => _NoteEditerRouteState();
}

class _NoteEditerRouteState extends State<NoteEditerRoute> {
  String _noteDetail;
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: widget.editor.createEditer(),
    );
  }
}
