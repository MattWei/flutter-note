import 'package:flutter/material.dart';

import '../note/note.dart';
import '../note/note_entity.dart';
import 'menu_item.dart';

class MenuNote extends StatefulWidget {
  MenuNote({Key key, this.note, @required this.noteSelectedNotifier})
      : super(key: key);

  final Note note;
  final NoteSelectedNotifier noteSelectedNotifier;

  @override
  _MenuNoteState createState() => _MenuNoteState();
}

class _MenuNoteState extends State<MenuNote> {
  IconData _getItemIcon(Note note) {
    return Icons.note;
  }


  @override
  Widget build(BuildContext context) {
      return MenuItem(
        note: widget.note,
        getIcon: _getItemIcon,
        noteSelectedNotifier: widget.noteSelectedNotifier);
  }
}
