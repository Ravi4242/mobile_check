import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

class MobileCheckConfig {
  final String projectType; // 'android', 'ios', 'flutter'
  final Map<String, dynamic> checks;

  MobileCheckConfig({required this.projectType, required this.checks});

  static Future<MobileCheckConfig?> load(String directory) async {
    final configPath = p.join(directory, '.mobilecheck.yml');
    if (!await File(configPath).exists()) {
      //print('No .mobilecheck.yml found. Using defaults.');
      return null;
    }

    final yamlString = await File(configPath).readAsString();
    final yamlMap = loadYaml(yamlString) as Map;
    return MobileCheckConfig(
      projectType: yamlMap['projectType'] ?? 'flutter',
      checks: yamlMap['checks'] ?? {},
    );
  }
}
