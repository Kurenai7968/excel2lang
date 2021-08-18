part of 'translation2json.dart';

class Language {
  late final String locale;
  late final Directory dir;
  Map<String, dynamic> lang = Map();

  Language({required String locale, required Directory dir}) {
    this.locale = locale;
    this.dir = dir;
  }

  Future<void> generateLanguageFile() async {
    if (!dir.existsSync()) await dir.create(recursive: true);
    File langFile = File('${dir.path}/$locale.json');
    String json = jsonEncode(lang);
    await langFile.writeAsString(json).then(
        (value) => print('$locale is generated at ${dir.path}/$locale.json'));
  }
}
