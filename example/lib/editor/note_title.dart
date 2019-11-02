import 'package:flutter/material.dart';

import 'editor_mode.dart';

class NoteTitleRoute extends StatefulWidget {
  NoteTitleRoute(
      {@required this.noteChangedNotifier,
      @required this.editorSwitchedNotifier,
      @required this.titleController,
      Key key})
      : super(key: key);

  final NoteChangedNotifier noteChangedNotifier;
  final EditorSwitchedNotifier editorSwitchedNotifier;
  final TextEditingController titleController;

  @override
  _NoteTitleRouteState createState() => _NoteTitleRouteState();
}

class _NoteTitleRouteState extends State<NoteTitleRoute> {


  @override
  initState() {
    super.initState();
    widget.noteChangedNotifier.addListener(_handleNoteChanged);
    widget.editorSwitchedNotifier.addListener(_handleEditModeChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          _showTitle(context),
        ],
      ),
    );
  }

  bool _isReadOnly() {
    return widget.noteChangedNotifier.value == null ||
          widget.editorSwitchedNotifier.value == EditorMode.view;
  }

  Widget _showTitle(BuildContext context) {
    return new TextField(
      controller: widget.titleController,
      style: TextStyle(fontFamily: 'NotoSerif'),
      readOnly: _isReadOnly(),
    );
  }

  void _setTitleText() {
    final titleController = widget.titleController;
    final title = widget.noteChangedNotifier.value.name;
    print('note title:$title');

    titleController.value = titleController.value.copyWith(
      text: title,
      selection:
          TextSelection(baseOffset: title.length, extentOffset: title.length),
      composing: TextRange.empty,
    );
  }

  void _handleNoteChanged() {
    _setTitleText();
    setState(() {});
  }

  void _handleEditModeChanged() {
    setState(() {
      
    });
  }
}
