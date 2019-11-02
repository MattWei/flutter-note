import 'dart:io';

import 'package:flutter/material.dart';

import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';

import '../note/note.dart';

class ZefyrNoteEditor {
  ZefyrController _zefyrController;
  final FocusNode _focusNode = new FocusNode();
  bool isChanged = false;
  Note note;

  void dispose() {
    _zefyrController.dispose();
  }

  Widget _createZefyrEditor(NotusDocument document) {
    _zefyrController = ZefyrController(document);

    _zefyrController.document.changes.listen((change) {
      final detail = _zefyrController.document.toString();
      print('note:$detail');
      isChanged = true;
    });

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

    return null;
  }

  Future<NotusDocument> _loadDocument() async {
    var delta = Delta()..insert('\n');
    final File file = note.entity;
    if (await file.exists()) {
      var contents = await file.readAsString();
      if (contents.isNotEmpty) {
        if (!contents.endsWith('\n')) {
          contents += '\n';
        }
        delta = Delta()..insert(contents);
      }
    }

    return NotusDocument.fromDelta(delta);
  }

  Widget createEditer() {
    return new FutureBuilder<NotusDocument>(
      builder: _editerBuilder,
      future: _loadDocument(),
    );
  }

  String getContent() {
    var text = _zefyrController.plainTextEditingValue.text;
    if (!text.endsWith('\n')) {
      text += '\n';
    }

    return text;
  }
}
