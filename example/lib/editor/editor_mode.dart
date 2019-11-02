import 'package:flutter/material.dart';

import '../note/note.dart';

enum EditorMode { edit, view }

class EditorSwitchedNotifier extends ValueNotifier<EditorMode> {
  EditorSwitchedNotifier(value) : super(value);
}

class NoteChangedNotifier extends ValueNotifier<Note> {
  NoteChangedNotifier(value) : super(value);
}