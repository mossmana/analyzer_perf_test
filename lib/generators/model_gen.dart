import 'dart:core';
import 'dart:io' show Directory, File;
import 'dart:math';
import 'package:analyzer_perf_test/model_util.dart';
import 'package:uuid/uuid.dart';


/// Generate the given number of random model classes. File will be stored
/// in a random folder in models/generated.
(List<String>, List<Map<String,String>>) generate({required int num}) {
  final generatedPath = '${Directory.current.path}/../models/generated';
  final subDirectories = <String>[Uuid().v4()];
  // Clear the contents
  final dir = Directory(generatedPath);
  dir.deleteSync(recursive: true);
  dir.createSync();
  var previousModelName = '';
  var previousModelSubDir = '';
  var modelLibraryFileContent = '';
  final modelNames = <String>[];
  final modelFieldMaps = <Map<String,String>>[];
  final (mixinFilecontent, mixinMap) = generateMixins(); 
  final mixinFilePath = '$generatedPath/mixins/generated_mixins.dart';
  File(mixinFilePath).create(recursive: true).then((file) {
    file.writeAsStringSync(mixinFilecontent);
  });
  for (var i = 0; i < num; i++) {
    final modelName = 'Model$i';
    // keep track of all model names
    modelNames.add(modelName);
    final modelFileName = 'model$i.dart';
    final (modelFileContent, modelFields) = generateRandomModelContent(modelName: modelName, 
      previousModelSubDir: previousModelSubDir, previousModelName: previousModelName, mixinMap: mixinMap);
    // keep track of all model fields
    modelFieldMaps.add(modelFields);
    final createNewSubDir = getRandomBool();
    dynamic subDir;
    // randomly decide to use an existing or new subdirectory
    if (createNewSubDir) {
      subDir = Uuid().v4();
      subDirectories.add(subDir);
    } else {
      subDir = subDirectories[Random().nextInt(subDirectories.length)];
    }
    previousModelSubDir = subDir;
    final modelFilePath = '$generatedPath/$subDir/$modelFileName';
    File(modelFilePath).create(recursive: true).then((file) {
      file.writeAsStringSync(modelFileContent);
    });
    previousModelName = modelName;
    final modelLibraryFileName = 'generated_models.dart';
    modelLibraryFileContent += 'export \'$subDir/$modelFileName\';\n';
    final libraryFilePath = '$generatedPath/$modelLibraryFileName';
    final libraryFile = File(libraryFilePath);
    libraryFile.writeAsStringSync(modelLibraryFileContent);
  }
  return (modelNames, modelFieldMaps);
}

/// Run this from the command line first before running the app
/// dart model_gen.dart
void main() {
  // A high number generates a stack overflow error
  generate(num: 100);
}
