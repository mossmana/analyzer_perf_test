import 'dart:math';
import 'package:uuid/uuid.dart';

const intType = 'int';
const doubleType = 'double';
const stringType = 'String';
const boolType= 'bool';
const dateTimeType = 'DateTime';
const intListType = 'List<int>';
const stringListType = 'List<String>';
const stringIntMapType = 'Map<String,int>';
const stringStringMapType = 'Map<String, String>';

// Create a list of data types.
const dataTypes = [
  intType,
  doubleType,
  stringType,
  boolType,
  dateTimeType,
  intListType,
  stringListType,
  stringIntMapType,
  stringStringMapType,
];

dynamic getRandomValueForField(String type) {
  switch (type) {
    case intType:
      return getRandomInt();
    case doubleType:
      return getRandomDouble();
    case stringType:
      return getRandomString();
    case boolType:
      return getRandomBool();
    case dateTimeType:
      return getRandomDateTime();
    case intListType:
      return getRandomIntList();
    case stringListType:
      return getRandomStringList();
    case stringIntMapType:
      return getRandomStringIntMap();
    case stringStringMapType:
      return getRandomStringStringMap();
    default:
      return '';
  }
}

int getRandomInt() {
  return Random(DateTime.now().millisecondsSinceEpoch).nextInt(5000);
}

double getRandomDouble() {
  return Random(DateTime.now().millisecondsSinceEpoch).nextDouble() * 5000;
}

String getRandomString() {
  return Uuid().v4();
}

bool getRandomBool() {
  final i = Random(DateTime.now().millisecondsSinceEpoch).nextInt(1);
  return i == 0;
}

DateTime getRandomDateTime() {
  // TODO(mossmana): allow for value larger than the max int 2^32 supported by Random.nextInt.
  const int maxInt = 4294967296;
  final randomMicroseconds = Random(DateTime.now().millisecondsSinceEpoch).nextInt(maxInt);
  return DateTime.fromMicrosecondsSinceEpoch(randomMicroseconds);
}

List<int> getRandomIntList() {
  final intList = List<int>.empty(growable: true);
  final length = getRandomInt();
  for (var i = 0; i < length; i++) {
    final value = Random(DateTime.now().millisecondsSinceEpoch).nextInt(10000);
    intList.add(value);
  }
  return intList;
}

List<String> getRandomStringList() {
  final stringList = List<String>.empty(growable: true);
  final length = getRandomInt();
  for (var i = 0; i < length; i++) {
    final value = getRandomString();
    stringList.add(value);
  }
  return stringList;
}

Map<String, int> getRandomStringIntMap() {
  final stringIntMap = <String,int>{};
  final length = getRandomInt();
  for (var i = 0; i < length; i++) {
    final key = getRandomString();
    final value = getRandomInt();
    stringIntMap[key] = value;
  }
  return stringIntMap;
}

Map<String, String> getRandomStringStringMap() {
  final stringStringMap = <String,String>{};
  final length = getRandomInt();
  for (var i = 0; i < length; i++) {
    final key = getRandomString();
    final value = getRandomString();
    stringStringMap[key] = value;
  }
  return stringStringMap;
}

/// This function generates a random model file with 50+ fields and a random number of functions.
/// Returns the file content and the field map.
(String, Map<String,String>) generateRandomModelContent(String modelName, String previousModelName) {
  final random = Random(DateTime.now().millisecondsSinceEpoch);
  final fieldMap = <String,String>{};
  var fieldStrings = '';
  final fields = <String>[];
  for (var i = 0; i < 50; i++) {
    final dataType = dataTypes[random.nextInt(dataTypes.length)];
    final fieldName = 'field$i';
    fields.add('  $dataType $fieldName;');
    fieldMap[fieldName] = dataType;
    fieldStrings += '$fieldName: \$$fieldName, ';
  }

  var header = '// ignore: camel_case_types\n';
  header += 'import \'package:analyzer_perf_test/model_util.dart\';\n';
  if (previousModelName.isNotEmpty) {
    fields.add('  $previousModelName model;');
    header += 'import \'package:analyzer_perf_test/models/generated/${previousModelName.toLowerCase()}.dart\';\n';
  }

  var modelFileContent = '''
$header
class $modelName {
${fields.join('\n')}

  $modelName({
${fields.map((field) => '    required this.${field.split(' ').last.replaceAll(';', '')},').join('\n')}
  });
''';

  int numFunctions = random.nextInt(500) + 1;
  for (int i = 0; i < numFunctions; i++) {
    final type = dataTypes[random.nextInt(dataTypes.length)];
    modelFileContent += '''
  $type randomFunction$i() {
    return getRandomValueForField('$type');
  }
''';
  }
  modelFileContent += '''
  @override
  String toString() {
    return '$modelName: {$fieldStrings}';
  }
}
''';

  return (modelFileContent, fieldMap);
}