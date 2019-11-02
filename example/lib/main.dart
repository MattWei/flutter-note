// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'editor/note.dart';
import 'menu/menu.dart';
import 'note/note.dart';
import 'note/note_entity.dart';
import 'note/notebook.dart';

import 'setting.dart';
import 'setting_dialog.dart';

void main() {
  // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(new MyApp());
}

/*
*/
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WNotes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // See https://github.com/flutter/flutter/wiki/Desktop-shells#fonts
        fontFamily: 'NotoSerif',
      ),
      home: MyHomePage(title: 'WNotes'),
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('zh', 'CN'), // Hebrew
        // ... other locales the app supports
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Notebook _rootNotebook;
  final NoteSelectedNotifier _noteShowNotifier = NoteSelectedNotifier(null);
  final NoteSelectedNotifier _noteSelectedNotifier = NoteSelectedNotifier(null);
  bool _menuOnShow = true;

  @override
  initState() {
    super.initState();
    
    final _settings = new Setting();
    _rootNotebook = new Notebook(Directory(_settings.rootPath), true, null);

    _noteSelectedNotifier.addListener(_handleNoteSelected);
  }

  void _handleNoteSelected() {
    final selectedEntity = _noteSelectedNotifier.value;
    if (selectedEntity is Note) {
      _noteShowNotifier.value = selectedEntity;
    }
  }

  Widget _getMenu() {
    if (_menuOnShow) {
      return Expanded(
        flex: 1,
        child: new Menu(
            rootNotebook: _rootNotebook,
            noteSelectedNotifier: _noteSelectedNotifier),
      );
    } else {
      return new Padding(
        padding: EdgeInsets.all(0),
      );
    }
  }

  Widget _showSpider() {
    return Container(
      color: Colors.green,
      width: 5,
      child: new GestureDetector(
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          print(details.primaryDelta);
        },
      ),
    );
  }

  Widget _showNote() {
    return Expanded(
      flex: 3,
      child: new NoteRoute(noteChangedNotifier: _noteShowNotifier),
    );
  }

  void _reloadNewSetting() {
    //_settings = new Setting();
  }

  void _createSettingDialog(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingWidget(
        onApplyEvent: _reloadNewSetting,
      );
    }));
  }

  void _showMenu() {
    setState(() {
      _menuOnShow = !_menuOnShow;
    });
  }

  void _refreshNotes() {

  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: Icon(Icons.menu), onPressed: _showMenu),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _refreshNotes,
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => _createSettingDialog(context),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Row(
          children: <Widget>[
            _getMenu(),
            _showSpider(),
            _showNote(),
          ],
        ),
      ),
    );
  }
}
