import 'package:flutter/material.dart';

import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'dart:io' show File, FileSystemEntity;

class NoteSavedNotifier extends ValueNotifier<FileSystemEntity> {
  NoteSavedNotifier(value) : super(value);

  void saveTo(FileSystemEntity entity) {
    if (entity != value) {
      value = entity;
    } else {
      notifyListeners();
    }
  }
}

class NoteEditerRoute extends StatefulWidget {
  NoteEditerRoute(
      {Key key, @required this.noteEntity, @required this.noteSaveNotifier})
      : super(key: key);

  final FileSystemEntity noteEntity;
  final NoteSavedNotifier noteSaveNotifier;

  @override
  _NoteEditerRouteState createState() => _NoteEditerRouteState();
}

class _NoteEditerRouteState extends State<NoteEditerRoute> {
  ZefyrController _zefyrController = new ZefyrController(NotusDocument());
  final FocusNode _focusNode = new FocusNode();
  String _noteDetail;
  @override
  initState() {
    super.initState();

    widget.noteSaveNotifier.addListener(_handleNoteSave);

    _zefyrController.document.changes.listen((change) {
      setState(() {
        _noteDetail = _zefyrController.document.toString();
        print('note:$_noteDetail');
      });
    });
  }

  @override
  void dispose() {
    _zefyrController.dispose();
    super.dispose();
  }

  Widget _createZefyrEditor(NotusDocument document) {
    _zefyrController = ZefyrController(document);
    return ZefyrScaffold(
      child: ZefyrEditor(
        padding: EdgeInsets.all(16),
        controller: _zefyrController,
        focusNode: _focusNode,
      ),
    );
  }

  Widget _editerBuilder(context, AsyncSnapshot<NotusDocument> snapshot) {
    //在这里根据快照的状态，返回相应的widget
    if (snapshot.connectionState == ConnectionState.active ||
        snapshot.connectionState == ConnectionState.waiting) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return new Center(
          child: new Text(snapshot.error.toString()),
        );
      } else if (snapshot.hasData) {
        final doc = snapshot.data;
        return _createZefyrEditor(doc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new FutureBuilder<NotusDocument>(
        builder: _editerBuilder,
        future: _loadDocument(widget.noteEntity),
      ),
    );
  }

  Future<NotusDocument> _loadDocument(FileSystemEntity entity) async {
    var delta = Delta()..insert('\n');
    final file = File(entity.path);
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        delta = Delta()..insert(contents);
      }
    }

    return NotusDocument.fromDelta(delta);
  }

  void _handleNoteSave() {
    try {
      final noteDetail = _zefyrController.plainTextEditingValue.text;
      final filePath = widget.noteSaveNotifier.value.path;

      print('entity:$filePath');
      print('note:$noteDetail');

      File(filePath).writeAsStringSync(noteDetail);
    }
    catch (err) {
        print(err);
    }
  }
}
