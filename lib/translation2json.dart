library translation2json;

import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:excel/excel.dart';

part 'language_model.dart';

Future<void> genLanguageJson(List<String> arguments) async {
  final ArgParser argParser = ArgParser()
    ..addOption('saveDir',
        abbr: 's',
        help: 'Json generated directory',
        defaultsTo: 'assets/languages')
    ..addOption('excelPath',
        abbr: 'e', help: 'Excel relative path', defaultsTo: 'translation.xlsx')
    ..addFlag('helpFlag', abbr: 'h', help: 'Print this usage information', negatable: false);
  final ArgResults argResults = argParser.parse(arguments);
  final String _excelPath = argResults['excelPath'];
  final String _saveDir = argResults['saveDir'];

  if (argResults['helpFlag']) {
    stdout.writeln(argParser.usage);
    exit(0);
  }

  Directory _dir = Directory(_saveDir);
  File _excelFile = File(_excelPath);
  Excel _excel = Excel.decodeBytes(_excelFile.readAsBytesSync());
  Map<int, Language> _languages = Map();

  for (var table in _excel.tables.keys) {
    for (var row in _excel.tables[table]!.rows) {
      for (var column in row) {
        if (column != null) {
          int columnIndex = column.cellIndex.columnIndex;
          int rowIndex = column.cellIndex.rowIndex;
          bool isNotFirstCell = !(columnIndex == 0 && rowIndex == 0);

          if (isNotFirstCell) {
            if (rowIndex == 0) {
              // first row, add all language object
              _languages[columnIndex] =
                  Language(locale: column.value, dir: _dir);
            } else if (columnIndex != 0) {
              // add translation to Map
              String key = row[0]!.value.toString(); // json key
              _languages[columnIndex]!.lang[key] = column.value;
            }
          }
        }
      }
    }
  }

  await Future.forEach<Language>(
    _languages.values,
    (lang) async => await lang.generateLanguageFile(),
  ).then((_) => print('Language json file is generated finish'));
}
