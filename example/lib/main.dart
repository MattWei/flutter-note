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

import 'directory.dart';
import 'note.dart';
import 'save_file_dialog.dart';
import 'setting_dialog.dart';
import 'setting.dart';

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
  final NoteChangedNotifier _noteShowNotifier = NoteChangedNotifier(null);
  final NoteChangedNotifier _noteSelectedNotifier = NoteChangedNotifier(null);

  @override
  initState() {
    super.initState();
    _noteSelectedNotifier.addListener(_handleNoteSelected);
    _noteShowNotifier.addListener(_handleNoteShowed);
  }

  void _handleNoteSelected() {
    final selectedEntity = _noteSelectedNotifier.value;
    if (selectedEntity is File) {
      _noteShowNotifier.value = selectedEntity;
    }
  }

  void _handleNoteShowed() {
    final showedEntity = _noteShowNotifier.value;
    _noteSelectedNotifier.value = showedEntity;
  }

  Widget _showDirectory() {
    final _settings = new Setting();
    print('root folder ${_settings.rootPath}');
    return Expanded(
      flex: 1,
      child: new DirectoryRoute(
          path: _settings.rootPath,
          shrinkWrap: false,
          noteSelectedNotifier: _noteSelectedNotifier),
    );
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

  void _createNewNote() {
    _noteShowNotifier.value = null;
  }

  void _createNewFolder() {
    final folderPath = FileDialog.openSaveFileDialog('');
    if (folderPath != null && folderPath.isNotEmpty) {
      final newFolder = new Directory(folderPath);
      newFolder.createSync(recursive: true);

      print('create new folder $folderPath');
      _noteSelectedNotifier.value = newFolder;
      setState(() {});
    }
  }

  void _reloadNewSetting() {
    //_settings = new Setting();
  }

  void _createSettingDialog(BuildContext context) {
    //导航到新路由
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingWidget(
        onApplyEvent: _reloadNewSetting,
      );
    }));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: Size(100, 10),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.note_add),
              onPressed: _createNewNote,
            ),
            IconButton(
              icon: Icon(Icons.folder),
              onPressed: _createNewFolder,
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _createSettingDialog(context),
            )
          ],
        ),
      ),
    );
  }

/*
  Widget _contextBuilder(
      context, AsyncSnapshot<bool> snapshot) {
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
          child: new Text(snapshot.error),
        );
      } else if (snapshot.hasData) {
        return Row(
          children: <Widget>[
            _showDirectory(),
            _showSpider(),
            _showNote(),
          ],
        );
      }
    }
  }

  FutureBuilder<bool> _buildContext() {
    return new FutureBuilder<bool>(
      builder: _contextBuilder,
      future: _settings.initFromFile(),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Row(
          children: <Widget>[
            _showDirectory(),
            _showSpider(),
            _showNote(),
          ],
        ),
        //_buildContext(),
      ),
    );
  }
}
