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
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'directory.dart';
import 'note.dart';

void main() {
  // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(new MyApp());
}

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
  NoteChangedNotifier _noteChangedNotifier = NoteChangedNotifier(null);

  Widget _showDirectory() {
    return Expanded(
      flex: 1,
      child: new DirectoryRoute(
          path: '/home/weiminji/workspace/notes',
          shrinkWrap: false,
          noteSelectedNotifier: _noteChangedNotifier),
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
      child: new NoteRoute(noteChangedNotifier: _noteChangedNotifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          children: <Widget>[
            _showDirectory(),
            _showSpider(),
            _showNote(),
          ],
        ),
      ),
    );
  }
}
