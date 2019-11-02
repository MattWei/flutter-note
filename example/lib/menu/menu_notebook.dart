import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../note/note.dart';
import '../note/note_entity.dart';
import '../note/notebook.dart';

import 'menu_item.dart';
import 'menu_note.dart';

class MenuNoteBook extends StatefulWidget {
  MenuNoteBook({Key key, this.notebook, @required this.noteSelectedNotifier})
      : super(key: key);

  final Notebook notebook;
  final NoteSelectedNotifier noteSelectedNotifier;

  @override
  _MenuNoteBookState createState() => _MenuNoteBookState();
}

class _MenuNoteBookState extends State<MenuNoteBook> {
  @override
  initState() {
    super.initState();
    widget.notebook.statusChangedNotifier
        .addListener(_handleNotebookStatusChanged);
  }

  void _handleNotebookStatusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<FileSystemEntity>> _listSubnotes(String rootPath) async {
    final stream =
        new Directory(rootPath).list(recursive: false, followLinks: false);

    final lists = await stream.toList();
    lists.removeWhere((entity) => basename(entity.path).startsWith('.'));

    return lists;
  }

  Widget _notebookBuilder(
      context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
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
        final list = snapshot.data;
        return _buildListView(context, list);
      }
    }

    return null;
  }

  Widget _buildListView(BuildContext context, List<FileSystemEntity> list) {
    final notebook = widget.notebook;
    notebook.updateSubNotes(list);

    return new ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final entity = notebook.subNotes[index];
        if (entity is Note) {
          return MenuNote(
              note: entity, noteSelectedNotifier: widget.noteSelectedNotifier);
        } else {
          return MenuNoteBook(
              notebook: entity,
              noteSelectedNotifier: widget.noteSelectedNotifier);
        }
      },
      itemCount: list.length,
    );
  }

  void _onTab(Notebook notebook) {
    notebook.onSelect();
    setState(() {});
  }

  Widget _buildNotebookList(Notebook notebook) {
    if (notebook != null && notebook.expanded) {
      return Container(
        color: Colors.blue,
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
        child: FutureBuilder<List<FileSystemEntity>>(
            builder: _notebookBuilder,
            future: _listSubnotes(notebook.entity.path),
          ),
      );
    } else {
      return Container();
    }
  }

  IconData _getDirectoryItemIcon(Notebook notebook) {
    if (notebook.expanded) {
      return Icons.expand_less;
    } else {
      return Icons.expand_more;
    }
  }

  Widget _buildNotebookTitle(Notebook notebook) {
    if (notebook.isRoot) {
      return new Container();
    }

    return MenuItem(
        note: notebook,
        onTab: _onTab,
        getIcon: _getDirectoryItemIcon,
        noteSelectedNotifier: widget.noteSelectedNotifier);
  }

  Widget _createNotebookView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.amberAccent,
            width: double.maxFinite,
            child: _buildNotebookTitle(widget.notebook),
          ),
          Container(
            color: Colors.amberAccent,
            width: double.maxFinite,
            child: _buildNotebookList(widget.notebook),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notebookView = _createNotebookView(context);
    Timer expandTimer;
    return DragTarget<NoteEntity>(
      // 用来接收数据的 Widget
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return notebookView;
      },
      // 用来接收数据
      onAccept: (data) {
        expandTimer?.cancel();
        print('mv ${data.entity.path} to ${widget.notebook.entity.path}');
      },
      onWillAccept: (data) {
        final notebook = widget.notebook;
        final itemPath = data.entity.path;
        final currentPath = notebook.entity.path;
        if (currentPath.contains(itemPath)) {
          print(
              'not Accept ${data.entity.path} to ${widget.notebook.entity.path}');
          return false;
        }

        if (!notebook.expanded) {
          expandTimer = Timer(Duration(seconds: 2), () {
            setState(() {
              notebook.expanded = true;
            });
          });
        }

        print(
            'onWillAccept ${data.entity.path} to ${widget.notebook.entity.path}');
        return true;
      },
      onLeave: (data) {
        expandTimer?.cancel();

        print(
            'onWillAccept ${data.entity.path} to ${widget.notebook.entity.path}');
      },
    );
  }
}
