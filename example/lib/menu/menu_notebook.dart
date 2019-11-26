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
      final type = widget.notebook.statusChangedNotifier.value;
      if (type == NoteStatusType.ADD_ITEM ||
          type == NoteStatusType.REMOVE_ITEM) {
        setState(() {
        });
      }
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
              note: entity,
              noteSelectedNotifier: widget.noteSelectedNotifier,
              dragTargetNotifier: notebook.dragTargetNotifier);
        } else {
          if (notebook.dragTargetNotifier.value) {
            final Notebook childNotebook = entity;
            childNotebook.dragTargetNotifier.value = true;
          }
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
        noteSelectedNotifier: widget.noteSelectedNotifier,
        dragTargetNotifier: notebook.dragTargetNotifier);
  }

  Color _getAccentColor() {
    return Colors.white;
  }

  Widget _createNotebookView(BuildContext context) {
    return Theme(
      data: ThemeData(
        accentColor: _getAccentColor(),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.maxFinite,
              child: _buildNotebookTitle(widget.notebook),
            ),
            Container(
              width: double.maxFinite,
              child: _buildNotebookList(widget.notebook),
            )
          ],
        ),
      ),
    );
  }

  bool _checkMovePath(NoteEntity source) {
    final notebook = widget.notebook;
    final tPath = notebook.entity.path;
    final sParentPath = source.entity.parent.path;
    //直接子项，不移动
    if (sParentPath == tPath) {
      return false;
    }

    //父目录不能移动到子目录
    final sPath = source.entity.path;
    if (tPath.contains(sPath)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final notebookMenu = _createNotebookView(context);
    Timer expandTimer;
    return DragTarget<NoteEntity>(
      // 用来接收数据的 Widget
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return notebookMenu;
      },
      // 用来接收数据
      onAccept: (data) {
        expandTimer?.cancel();
        widget.notebook.onDragItems = false;

        if (!_checkMovePath(data)) {
          return true;
        }
        data.move(widget.notebook);
        setState(() {});
      },
      onWillAccept: (data) {
        if (!_checkMovePath(data)) {
          return true;
        }

        final notebook = widget.notebook;
        notebook.onDragItems = true;
        if (!notebook.expanded) {
          expandTimer = Timer(Duration(seconds: 1), () {
            setState(() {
              notebook.expanded = true;
            });
            //
          });
        }

        return true;
      },
      onLeave: (data) {
        expandTimer?.cancel();
        widget.notebook.onDragItems = false;
      },
    );
  }
}
