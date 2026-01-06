import 'package:mobile_check/checks/check_result.dart';
import 'package:path/path.dart' as p;
import 'config/mobilecheck_config.dart';
import 'checks/android_runner.dart';
import 'checks/ios_runner.dart';
import 'checks/flutter_runner.dart';

Future<List<CheckResult>> run(String projectDir, String platform) async {
  final config = await MobileCheckConfig.load(projectDir);
  final projectType = platform.toLowerCase();

  return switch (projectType) {
    'android' => AndroidRunner().runChecks(projectDir),
    //'ios' => _iosRunner(projectDir),
    //'flutter' => _flutterRunner(projectDir),
    _ => throw Exception('Unknown platform: $platform'),
  };
}
