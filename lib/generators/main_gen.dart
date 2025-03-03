// Helper function to generate random models
import 'dart:io';
import 'package:analyzer_perf_test/generators/model_gen.dart';

String generateGetModelsFunction(List<String> modelNames, List<Map<String,String>> modelFieldMaps) {
  var previousModel = '';
  var getModelsFunction = '''
List<dynamic> getModels() {
  final models = List<dynamic>.empty(growable: true);  
''';
  for (var i = 0; i < modelNames.length; i++) {
    final modelName = modelNames[i];
    final modelVarName = modelName.toLowerCase();
    final modelFieldMap = modelFieldMaps[i];
    getModelsFunction += '''
  var $modelVarName = $modelName(
''';
    modelFieldMap.forEach((fieldName, type) {
      getModelsFunction += '''
    $fieldName: getRandomValueForField('$type'),
''';
    });
    if (previousModel.isNotEmpty) {
      getModelsFunction += '''
    model: $previousModel,
''';
    }
    getModelsFunction += '''
  );
  models.add($modelVarName);
''';
    previousModel = modelVarName;
  }
  getModelsFunction += '''
  return models;
}
''';
  return getModelsFunction;
}

String generateMainContentUsingGeneratedModels(String getModelsFunction) {
  
  final mainContent = '''
import 'package:flutter/material.dart';
import 'package:analyzer_perf_test/models/generated/generated_models.dart';
import 'package:analyzer_perf_test/model_util.dart';

$getModelsFunction

class ModelViewer extends StatelessWidget {
  final List<dynamic> models;

  const ModelViewer({super.key, required this.models});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Viewer'),
      ),
      body: ListView.builder(
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];
          return ListTile(
            title: Text(model.runtimeType.toString()),
            subtitle: Text(
              // Display the first 3 fields (or less if there are fewer)
              model.toString(),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailPage(model: model), // Pass the model
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final dynamic model;

  const DetailPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail View - \${model.runtimeType}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(model.toString()), // Display all fields
      ),
    );
  }
}

void main() {
  final models = getModels();
  runApp(MaterialApp(
    home: ModelViewer(models: models),
  ));
}
''';

  return mainContent;
}

void main() {
  final (modelNames, modelFieldMaps) = generate(num: 10);
  final path = Directory.current.path;
  final mainFileName = 'main.dart';
  final getModelsFunction = generateGetModelsFunction(modelNames, modelFieldMaps);
  final mainFileContent = generateMainContentUsingGeneratedModels(getModelsFunction);
  final mainFilePath = '$path/../$mainFileName';
  final mainFile = File(mainFilePath);
  mainFile.writeAsStringSync(mainFileContent);
}