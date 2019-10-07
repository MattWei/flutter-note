import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NoteViewerRoute extends StatefulWidget {
  NoteViewerRoute({Key key, @required this.noteEntity}) : super(key: key);

  final FileSystemEntity noteEntity;

  @override
  _NoteViewerRouteState createState() => _NoteViewerRouteState();
}

class _NoteViewerRouteState extends State<NoteViewerRoute> {

  @override
  Widget build(BuildContext context) {
    final _entity = widget.noteEntity;
    String _note;

    if (_entity != null) {
      try {
        final noteFile = new File('${_entity.path}');
        _note = noteFile.readAsStringSync();
      } on FileSystemException {
        _note = '';
      }
    }

    try {
        return new Markdown(data: _note);
      } on NetworkImageLoadException {
        print('Something wrong on network');
        return new Container();
      }
  }
}