import 'package:flutter/material.dart';

import '../note/note.dart';
import '../note/note_entity.dart';
import '../note/notebook.dart';

class _NameInputDialog {
  _NameInputDialog(this.context, this.title);
  BuildContext context;
  String input = '';
  String title = '';

  Future<bool> _showInputDialog(String defaultValue, String errorText) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (context) {
        final textEditingController = TextEditingController.fromValue(
            TextEditingValue(
                text: '$defaultValue', //判断keyword是否为空
                // 保持光标在最后

                selection: TextSelection.fromPosition(TextPosition(
                    affinity: TextAffinity.downstream,
                    offset: '$defaultValue'.length))));
        return AlertDialog(
          title: Text(title),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(errorText: errorText),
                  controller: textEditingController,
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                input = textEditingController.value.text;
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> showInputDialog(String defaultValue, String errorText) async {
    var onError = '';
    input = defaultValue;
    do {
      final isOk = await _showInputDialog(input, onError);
      if (!isOk) {
        return '';
      }

      onError = errorText;
    } while (input == '');

    return input;
  }
}

class MenuToolsBar extends StatefulWidget {
  MenuToolsBar({@required this.noteSelectedNotifier, Key key})
      : super(key: key);

  final NoteSelectedNotifier noteSelectedNotifier;
  @override
  _MenuToolsBarState createState() => _MenuToolsBarState();
}

class _MenuToolsBarState extends State<MenuToolsBar> {
  @override
  initState() {
    super.initState();
    widget.noteSelectedNotifier.addListener(_handleSelectedNoteChanged);
  }

  void _handleSelectedNoteChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _createButton(Icon icon, onPressed) {
    return SizedBox(
        width: 35.0,
        height: 35.0,
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
        ));
  }

  Function _getEditButtonOnPressedFunction() {
    final noteEntity = widget.noteSelectedNotifier.value;
    if (noteEntity == null || noteEntity is Note) {
      return null;
    }

    return _renameMenuItem;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text('Notes'),
        ),
        _createButton(Icon(Icons.note_add), _createNewNote),
        _createButton(Icon(Icons.folder), _createNewFolder),
        _createButton(Icon(Icons.settings), _getEditButtonOnPressedFunction()),
      ],
    );
  }

  Future<void> _ackAlert(BuildContext context, String title, String content) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _createNewNote() async {
    var newNoteTitle = 'NewNote';
    const errorText = 'Can not be empty';

    final dialog = new _NameInputDialog(context, 'Enter note name');
    newNoteTitle = await dialog.showInputDialog(newNoteTitle, errorText);
    if (newNoteTitle == '') return;

    final parentNotebook = _getParentNotebook();
    final res = parentNotebook.createSubnote(newNoteTitle);
    if (res != 'OK') {
      await _ackAlert(context, 'Create error', res);
    }
  }

  Notebook _getParentNotebook() {
    var entity = widget.noteSelectedNotifier.value;
    if (entity is Note) {
      entity = entity.parent;
    }

    return entity;
  }

  void _createNewFolder() async {
    var newNoteBook = 'NewNoteBook';
    const errorText = 'Can not be empty';

    final dialog = new _NameInputDialog(context, 'Enter notebook name');
    newNoteBook = await dialog.showInputDialog(newNoteBook, errorText);
    if (newNoteBook == '') return;

    final parentNotebook = _getParentNotebook();
    final res = parentNotebook.createSubnotebook(newNoteBook);
    if (res != 'OK') {
      await _ackAlert(context, 'Create error', res);
    }
  }

  void _renameMenuItem() async {
    final entity = widget.noteSelectedNotifier.value;
    if (entity == null) {
      return;
    }

    var itemName = entity.name;
    const errorText = 'Can not be empty';

    final dialog = new _NameInputDialog(context, 'rename');
    itemName = await dialog.showInputDialog(itemName, errorText);
    if (itemName == '') return;

    entity.rename(itemName);
  }
}
