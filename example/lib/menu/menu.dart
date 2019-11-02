import 'package:flutter/material.dart';

import '../note/note_entity.dart';
import '../note/notebook.dart';

import 'menu_notebook.dart';
import 'menu_toolsbar.dart';

class Menu extends StatefulWidget {
  Menu({Key key, this.rootNotebook, @required this.noteSelectedNotifier})
      : super(key: key);

  final Notebook rootNotebook;
  final NoteSelectedNotifier noteSelectedNotifier;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    final noteSelectedNotifier = widget.noteSelectedNotifier;
    return Container(
        child: Column(
      children: <Widget>[
        MenuToolsBar(noteSelectedNotifier: noteSelectedNotifier,),
        Expanded(
          flex: 1,
          child: MenuNoteBook(
              notebook: widget.rootNotebook,
              noteSelectedNotifier: noteSelectedNotifier),
        )
      ],
    ));
  }
}
