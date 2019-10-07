import 'package:flutter/material.dart';
import 'setting.dart';
import 'save_file_dialog.dart';

class SettingWidget extends StatefulWidget {
  Function onApplyEvent;

  SettingWidget({
    Key key,
    @required this.onApplyEvent,
  }) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingWidget> {
  //final Setting _setting = new Setting();
  final TextEditingController _rootPathController = new TextEditingController();

  //initState() {
  //  super.initState();
  //}

  void _setRootPathController(String rootFolder) {
    _rootPathController.value = _rootPathController.value.copyWith(
      text: rootFolder,
      selection: TextSelection(
          baseOffset: rootFolder.length, extentOffset: rootFolder.length),
      composing: TextRange.empty,
    );

    return;
  }

  String _getRootFolderText() {
    final title = _rootPathController.text;
    if (title.isEmpty) {
      return '';
    }

    return title;
  }

  void _changeRootFolder() {
    final _setting = new Setting();
    final filePath = FileDialog.openSelectFolderDialog(_setting.rootPath);
    if (filePath != null && filePath.isNotEmpty) {
      print('select $filePath to root path');
      _setRootPathController(filePath);
    }
  }

  Widget _buildSettingViews() {
    return Expanded(
      flex: 1,
      child: Column(
        children: <Widget>[
          _buildRootFolderSetting(),
          Spacer(
            flex: 1,
          )
        ],
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
        return _buildSettingViews();
      }
    }
  }

  FutureBuilder<bool> _buildContext() {
    return new FutureBuilder<bool>(
      builder: _contextBuilder,
      future: _setting.initFromFile(),
    );
  }
  */

  Widget _buildRootFolderSetting() {
    final _setting = new Setting();
    _setRootPathController(_setting.rootPath);
    return Row(
      children: <Widget>[
        Text('root path:'),
        Expanded(
          flex: 1,
          child: TextField(
            controller: _rootPathController,
            style: TextStyle(fontFamily: 'NotoSerif'),
            readOnly: true,
          ),
        ),
        RaisedButton(
          child: Text('Browse'),
          onPressed: _changeRootFolder,
        )
      ],
    );
  }

  void _applyChanged() {
    final rootPath = _getRootFolderText();
    print('new root folder $rootPath');
    if (rootPath.isEmpty) {
      return;
    }

    final _setting = new Setting();
    _setting.rootPath = rootPath;
    _setting.save();
    widget.onApplyEvent();
  }

  Widget _buildBottomButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        RaisedButton(
          child: Text('Apply'),
          onPressed: _applyChanged,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            _buildSettingViews(),
            //_buildContext(),
            _buildBottomButton(),
          ],
        ),
      )),
    );
  }
}
