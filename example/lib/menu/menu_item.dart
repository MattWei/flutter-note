import 'package:flutter/material.dart';

import '../note/note_entity.dart';

class MenuItem extends StatefulWidget {
  MenuItem({
    @required this.noteSelectedNotifier,
    @required this.getIcon,
    @required this.note,
    Key key,
    this.onTab,
    this.dragTargetNotifier
  }) : super(key: key);

  final NoteEntity note;
  final NoteSelectedNotifier noteSelectedNotifier;
  final onTab;
  final getIcon;
  final DragTargetNotifier dragTargetNotifier;
  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _isOnDragTarget = false;

  @override
  initState() {
    super.initState();
    widget.note.statusChangedNotifier.addListener(_handleNoteStatusChanged);
    widget.noteSelectedNotifier.addListener(_handleSelectedNoteChanged);

    if (widget.dragTargetNotifier != null) {
      widget.dragTargetNotifier.addListener(_handleDragTarget);
      _isOnDragTarget = widget.dragTargetNotifier.value;
    }
  }

  bool _updateSelectedStatus() {
    final note = widget.note;
    final showingFile = widget.noteSelectedNotifier.value;
    if (showingFile != null && note == showingFile) {
      if (!note.onSelected) {
        note.onSelected = true;
        return true;
      }

      return false;
    }

    if (note.onSelected) {
      note.onSelected = false;
      return true;
    }

    return false;
  }

  void _handleNoteStatusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSelectedNoteChanged() {
    if (mounted) {
      if (_updateSelectedStatus()) {
        setState(() {

        });
      }
    }
  }

  void _handleDragTarget() {
    if (mounted) {
      setState(() {
        _isOnDragTarget = widget.dragTargetNotifier.value;
      });

    }
  }

  Color _getBackgroud(NoteEntity note) {
    if (note.onSelected) {
      return Colors.grey;
    }

    if (_isOnDragTarget) {
      return Colors.blue;
    }

    return Theme.of(context).accentColor;
  }

  void _onTab(NoteEntity note) {
    widget.noteSelectedNotifier.value = note;
    note.onSelected = true;

    if (widget.onTab != null) {
      widget.onTab(note);
    }
  }

  Widget _buildItem() {
    final note = widget.note;
    return Material(
        color: _getBackgroud(note),
        child: InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                widget.getIcon(note),
                size: 15,
              ),
              Flexible(
                child: new Text(
                  note.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: new TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => _onTab(note),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final menuItem = _buildItem();
    return Draggable<NoteEntity>(
      data: widget.note,
      child: menuItem,
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: menuItem,
      ),
      feedback: menuItem,
    );
  }
}
