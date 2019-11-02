import 'package:flutter/material.dart';

import '../note/note_entity.dart';

class MenuItem extends StatefulWidget {
  MenuItem({
    @required this.noteSelectedNotifier,
    @required this.getIcon,
    @required this.note,
    Key key,
    this.onTab,
  }) : super(key: key);

  final NoteEntity note;
  final NoteSelectedNotifier noteSelectedNotifier;
  final onTab;
  final getIcon;
  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  initState() {
    super.initState();
    widget.note.statusChangedNotifier.addListener(_handleNoteStatusChanged);
    widget.noteSelectedNotifier.addListener(_handleSelectedNoteChanged);
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
        setState(() {});
      }
    }
  }

  Color _getBackgroud(NoteEntity note) {
    if (note.onSelected) {
      return Colors.grey;
    }

    return Colors.white;
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
    return new Material(
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
