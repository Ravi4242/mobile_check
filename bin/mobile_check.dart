import 'dart:io';
import 'package:args/args.dart';
import 'package:mobile_check/checks/check_result.dart';
import 'package:mobile_check/config/mobilecheck_config.dart';
import 'package:path/path.dart';
import '../lib/mobile_check.dart' as MobileCheck;
import 'package:path/path.dart' as p;


Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addOption('platform', abbr: 'p', allowed: ['android', 'ios', 'flutter'], help: 'Platform to check')
    ..addOption('dir', abbr: 'd', defaultsTo: '.', help: 'Project directory');

  final results = parser.parse(arguments);

  if (results['help'] as bool) {
    print(parser.usage);
    return;
  }

  final projectDir = p.absolute(results['dir'] as String);
  await runMobileCheck(projectDir, results['platform'] as String?);
}

Future<void> runMobileCheck(String projectDir, String? platformArg) async {
  print('🔍 Checking $projectDir for release readiness...\n');

  final config = await MobileCheckConfig.load(projectDir);
  // Auto-detect if no platform specified
  final platform = platformArg ?? await _detectProjectType(projectDir);
  
  final results = await MobileCheck.run(projectDir, platform);

  // Print individual results
  for (final result in results) {
    print(result.toString());
  }

  // Summary
  final passes = results.where((r) => r.status == CheckStatus.pass).length;
  final warns = results.where((r) => r.status == CheckStatus.warn).length;
  final fails = results.where((r) => r.status == CheckStatus.fail).length;

  print('\n📊 SUMMARY: $passes pass, $warns warn, $fails fail');
  if (fails > 0) {
    print('\n❌ Release blocked. Fix failures above.');
    exit(1);
  }
  print('\n🎉 Release looks good!');
}

Future<String> _detectProjectType(String projectDir) async {
  if (await Directory(join(projectDir, 'app')).exists()) return 'android';
  if (await Directory(join(projectDir, 'ios')).exists()) return 'ios';
  if (await File(join(projectDir, 'pubspec.yaml')).exists()) return 'flutter';
  throw Exception('Cannot detect project type in $projectDir');
}
