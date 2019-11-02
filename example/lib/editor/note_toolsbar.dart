import 'package:flutter/material.dart';

import 'editor_mode.dart';

class TitleToolsBarRoute extends StatefulWidget {
  TitleToolsBarRoute(
      {@required this.editorSwitchedNotifier,
      @required this.noteStatusChangedNotifier,
      @required this.titleController,
      Key key})
      : super(key: key);

  final EditorSwitchedNotifier editorSwitchedNotifier;
  final NoteChangedNotifier noteStatusChangedNotifier;
  final TextEditingController titleController;
  @override
  _TitleToolsBarState createState() => _TitleToolsBarState();
}

class _TitleToolsBarState extends State<TitleToolsBarRoute> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: _createToolsbar(),
      onPressed: _getOnPressFunction(),
    );
  }

Function _getOnPressFunction() {
  if (widget.noteStatusChangedNotifier.value != null) {
    return _toolsBarOnPress;
  }

  return null;
}

  Widget _createToolsbar() {
    final editroMode = widget.editorSwitchedNotifier.value;
    var button = '';
    if (editroMode == EditorMode.edit) {
      button = 'Save';
    } else if (editroMode == EditorMode.view) {
      button = 'Edit';
    }

    return new Text(button);
  }

  Widget _generateAlertDialog(BuildContext context) {
    return AlertDialog(
      content: Text('Note title can not be empty'),
      actions: <Widget>[
        FlatButton(
          child: Text('确认'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _toolsBarOnPress() {
    final editroMode = widget.editorSwitchedNotifier.value;
    if (editroMode == EditorMode.edit) {
      final title = widget.titleController.value.text;
      if (title == null || title.isEmpty) {
        showDialog(
          context: context, builder: (_) => _generateAlertDialog(context));
        return;
      }

      widget.editorSwitchedNotifier.value = EditorMode.view;
    } else if (editroMode == EditorMode.view) {
      widget.editorSwitchedNotifier.value = EditorMode.edit;
    }

    setState(() {});
  }
}
