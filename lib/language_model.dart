part of 'excel2lang.dart';

class Language {
  late final String locale;
  late final Directory dir;
  late final String extension;
  Map<String, dynamic> lang = Map();

  Language({required this.locale, required this.dir, required this.extension});

  Future<void> generateLanguageFile() async {
    if (!dir.existsSync()) await dir.create(recursive: true);
    String fileName = '$locale.$extension';

    File langFile = File('${dir.path}/$fileName');
    String json = jsonEncode(lang);
    String prettyJson = _prettyJson(json);
    String dartMap =
        '// ignore: constant_identifier_names\nconst Map<String, String> $locale = ${prettyJson};';
    String result = extension == 'dart' ? dartMap : prettyJson;

    await langFile.writeAsString(result).then(
        (value) => print('$locale is generated at ${dir.path}/$fileName'));
  }

  String _prettyJson(String input) {
    JsonDecoder decoder = const JsonDecoder();
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    var object = decoder.convert(input);
    var prettyString = encoder.convert(object);
    return prettyString;
  }
}
