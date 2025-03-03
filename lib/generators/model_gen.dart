import 'dart:io' show Directory, File;
import 'package:analyzer_perf_test/model_util.dart';

/// Generate the given number of random model classes
(List<String>, List<Map<String,String>>) generate({required int num}) {
  final generatedPath = '${Directory.current.path}/../models/generated';
  // Clear the contents
  final dir = Directory(generatedPath);
  dir.deleteSync(recursive: true);
  dir.createSync();
  var previousModelName = '';
  var libraryFileContent = '';
  final modelNames = List<String>.empty(growable: true);
  final modelFieldMaps = List<Map<String,String>>.empty(growable: true);
  for (var i = 0; i < num; i++) {
    final modelName = 'Model$i';
    modelNames.add(modelName);
    final modelFileName = 'model$i.dart';
    final (modelFileContent, modelFields) = generateRandomModelContent(modelName, previousModelName);
    modelFieldMaps.add(modelFields);
    final modelFilePath = '$generatedPath/$modelFileName';
    final modelFile = File(modelFilePath);
    modelFile.writeAsStringSync(modelFileContent);
    previousModelName = modelName;
    final libraryFileName = 'generated_models.dart';
    libraryFileContent += 'export \'$modelFileName\';\n';
    final libraryFilePath = '$generatedPath/$libraryFileName';
    final libraryFile = File(libraryFilePath);
    libraryFile.writeAsStringSync(libraryFileContent);
  }
  return (modelNames, modelFieldMaps);
}

/// Run this from the command line first before running the app
/// dart model_gen.dart
void main() {
  // A high number generates a stack overflow error
  generate(num: 100);
}
