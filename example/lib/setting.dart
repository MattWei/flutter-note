import 'dart:convert' show json;
import 'dart:io';

class Setting {
  static const _settingFile = 'assets/settings.json';
  String rootPath;

  Setting() {
    final settingFile = new File(_settingFile);
    final settings = settingFile.readAsStringSync();
    _initFromJson(json.decode(settings));
  }

  Map<String, dynamic> toJson() => {'rootPath': rootPath};

  void _initFromJson(Map<String, dynamic> json) {
    rootPath = json['rootPath'];
  }

  void save() async {
    new File(_settingFile).writeAsStringSync(json.encode(this));
  }
}
