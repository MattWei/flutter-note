import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'dart:io';

import 'note.dart';

class DirectoryRoute extends StatefulWidget {
  DirectoryRoute(
      {Key key,
      this.path,
      this.shrinkWrap,
      @required this.noteSelectedNotifier})
      : super(key: key);

  final String path;
  final bool shrinkWrap;
  final NoteChangedNotifier noteSelectedNotifier;

  @override
  _DirectoryRouteState createState() => _DirectoryRouteState();
}

class _DirectoryRouteState extends State<DirectoryRoute> {
  final List<String> _expendDirectory = <String>[];
  @override
  initState() {
    super.initState();
    widget.noteSelectedNotifier.addListener(_handleNoteChanged);
  }

  void _handleNoteChanged() {
    if (mounted) {
      setState(() {
        final note = widget.noteSelectedNotifier.value;
        if (note == null)
          return;

        final parent = widget.noteSelectedNotifier.value.parent;
        final rootPath = widget.path;
        if (parent.path.contains(rootPath)) {
          final subDir = parent.path.substring(rootPath.length);
          if (subDir.isEmpty) {
            return;
          }

          final folders = subDir.split('/');
          var firstFolder = folders[0];
          if (firstFolder.isEmpty) {
            firstFolder = '$rootPath/${folders[1]}';
          } else {
            firstFolder = '$rootPath/$firstFolder';
          }

          if (!_expendDirectory.contains(firstFolder)) {
            print('add $firstFolder to _expendDirectory');
            _expendDirectory.add(firstFolder);
          }
        }
      });
    }
  }

  Future<List<FileSystemEntity>> listDirectory(String rootPath) async {
    final stream =
        new Directory(rootPath).list(recursive: false, followLinks: false);

    final lists = await stream.toList();
    lists.removeWhere((entity) => basename(entity.path).startsWith('.'));

    return lists;
  }

  FutureBuilder<List<FileSystemEntity>> _buildDirectoryFileList(String path) {
    assert(path != null && path.isNotEmpty);

    return new FutureBuilder<List<FileSystemEntity>>(
      builder: _directoryFileListBuilder,
      future: listDirectory(path),
    );
  }

  Widget _directoryFileListBuilder(
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
  }

  bool _isExtendDirectory(FileSystemEntity entity) {
    return entity is Directory && _expendDirectory.contains(entity.path);
  }

  Color _getBackgroud(FileSystemEntity entity) {
    //print('selected file $_selectedFile');
    final showingFile = widget.noteSelectedNotifier.value;
    if (showingFile != null && entity.path == showingFile.path) {
      return Colors.grey;
    }
    return Colors.white;
  }

  Widget _buildItem(FileSystemEntity entity, IconData icon,
      void onItemTab(FileSystemEntity entity)) {
    return new Material(
        color: _getBackgroud(entity),
        child: new InkWell(
          child: new Row(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                child: new Icon(
                  icon,
                  size: 15,
                ),
              ),
              new Expanded(
                child: new Text(
                  basename(entity.path),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: new TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ],
          ),

          onTap: () => onItemTab(entity), //点击
        ));
  }

  Widget _buildSubList(FileSystemEntity entity) {
    if (_isExtendDirectory(entity)) {
      return new Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 0.0, 10.0, 0.0),
        child: new DirectoryRoute(
          path: entity.path,
          shrinkWrap: true,
          noteSelectedNotifier: widget.noteSelectedNotifier,
        ),
      );
    }

    return new Container();
  }

  IconData _getDirectoryItemIcon(FileSystemEntity entity) {
    if (_isExtendDirectory(entity)) {
      return Icons.expand_less;
    } else {
      return Icons.expand_more;
    }
  }

  void _onDirectoryItemTap(FileSystemEntity entity) {
    if (_isExtendDirectory(entity)) {
      _expendDirectory.remove(entity.path);
    } else {
      _expendDirectory.add(entity.path);
    }

    setState(() {
      print('update file list');
    });
  }

  Widget _buildDirectoryItem(FileSystemEntity entity) {
    return new Column(
      children: <Widget>[
        _buildItem(entity, _getDirectoryItemIcon(entity), _onDirectoryItemTap),
        _buildSubList(entity),
      ],
    );
  }

  void _onFileTab(FileSystemEntity entity) {
    print('file tab ${entity.path}');
    //_selectedFile = entity;
    widget.noteSelectedNotifier.value = entity;
    setState(() {});
  }

  Widget _buildFileItem(FileSystemEntity entity) {
    return _buildItem(entity, Icons.note, _onFileTab);
  }

  Widget _buildListView(BuildContext context, List<FileSystemEntity> list) {
    return new ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      itemBuilder: (context, index) {
        final entity = list[index];
        if (entity is File) {
          return _buildFileItem(entity);
        } else {
          return _buildDirectoryItem(entity);
        }
      },
      itemCount: list.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildDirectoryFileList(widget.path),
    );
  }
}
