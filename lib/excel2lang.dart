library excel2lang;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:excel/excel.dart';

part 'language_model.dart';

Future<void> genLanguageFile(List<String> arguments) async {
  final ArgParser argParser = ArgParser()
    ..addOption('saveDir',
        abbr: 'd',
        help: 'Directory for generated file',
        defaultsTo: 'assets/languages')
    ..addOption('excelPath',
        abbr: 'f', help: 'Excel relative path', defaultsTo: 'translation.xlsx')
    ..addOption('extension',
        abbr: 'e', help: 'Extension for generated file', defaultsTo: 'json')
    ..addFlag('helpFlag',
        abbr: 'h', help: 'Print this usage information', negatable: false);
  final ArgResults argResults = argParser.parse(arguments);
  final String _excelPath = argResults['excelPath'];
  final String _saveDir = argResults['saveDir'];
  final String _extension = argResults['extension'];

  if (argResults['helpFlag']) {
    stdout.writeln(argParser.usage);
    exit(0);
  }

  if (!(_extension == 'json' || _extension == 'dart')) {
    print('Extension must be json or dart');
    exit(0);
  }

  if (!(await File(_excelPath).exists())) {
    print('Excel file not found');
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
              _languages[columnIndex] = Language(
                  locale: column.value, dir: _dir, extension: _extension);
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
  ).then((_) => print('Language file is generated finish'));
}
