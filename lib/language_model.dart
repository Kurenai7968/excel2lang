part of 'excel2lang.dart';

class Language {
  late final String locale;
  late final Directory dir;
  late final String extension;
  late final String dartPartOf;
  Map<String, dynamic> lang = Map();

  Language({
    required this.locale,
    required this.dir,
    required this.extension,
    required this.dartPartOf,
  });

  Future<void> generateLanguageFile() async {
    if (!dir.existsSync()) await dir.create(recursive: true);
    String fileName = '$locale.$extension';

    File file = File('${dir.path}/$fileName');
    String json = jsonEncode(lang);
    String prettyJson = _prettyJson(json);
    String dartMap = _dartMap(prettyJson);
    String result = extension == 'dart' ? dartMap : prettyJson;

    await file
        .writeAsString(result)
        .then((value) => print('$locale is generated at ${file.path}'));
  }

  String _prettyJson(String input) {
    JsonDecoder decoder = const JsonDecoder();
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    var object = decoder.convert(input);
    var prettyString = encoder.convert(object);
    return prettyString;
  }

  String _dartMap(String json) {
    List<String> localeList = locale.split('_');
    String variableName = '${localeList[0]}${localeList[1].toUpperCase()}';
    String dartMap = "part of '$dartPartOf.dart';\n\n";
    // dartMap += '// ignore: constant_identifier_names\n';
    dartMap += 'const Map<String, String> $variableName = ${json};';
    return dartMap;
  }
}
