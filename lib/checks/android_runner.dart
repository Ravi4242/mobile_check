import 'dart:io';
import 'package:mobile_check/checks/check_result.dart';
import 'package:path/path.dart' as p;

class AndroidRunner {
  Future<List<CheckResult>> runChecks(String rootDir) async {
    final results = <CheckResult>[];

    // Check 1: Version bump
    results.addAll(await _checkVersionBump(rootDir));

    // Check 2: Changelog updated
    results.addAll(await _checkChangelog(rootDir));

    // Check 3: Release signing config
    results.addAll(await _checkSigningConfig(rootDir));

    return results;
  }

  Future<List<CheckResult>> _checkVersionBump(String rootDir) async {
    final gradlePath1 = p.join(rootDir, 'app', 'build.gradle');
    final gradlePath2 = p.join(rootDir, 'app', 'build.gradle.kts');
    if (!await File(gradlePath1).exists() &&
        !await File(gradlePath2).exists()) {
      return [
        CheckResult(
            id: 'version-bump',
            description: 'No app/build.gradle found',
            status: CheckStatus.fail)
      ];
    }

    // Simple regex check - expand as needed
    String? content;
    try {
      content = await File(gradlePath1).readAsString();
    } on Exception catch (e) {
      try {
        content = await File(gradlePath2).readAsString();
      } on Exception catch (e) {
        return [
          CheckResult(
              id: 'version-bump',
              description: 'No app/build.gradle found',
              status: CheckStatus.fail)
        ];
      }
    }
    if (!content.contains('versionCode') || !content.contains('versionName')) {
      return [
        CheckResult(
            id: 'version-bump',
            description: 'versionCode/versionName not found in build.gradle',
            status: CheckStatus.fail)
      ];
    }
    return [
      CheckResult(
          id: 'version-bump',
          description: 'Version config present',
          status: CheckStatus.pass)
    ];
  }

  Future<List<CheckResult>> _checkChangelog(String rootDir) async {
    final changelogPath = p.join(rootDir, 'CHANGELOG.md');
    if (!await File(changelogPath).exists()) {
      return [
        CheckResult(
            id: 'changelog',
            description: 'No CHANGELOG.md found',
            status: CheckStatus.warn,
            details: 'Create one for release notes')
      ];
    }
    return [
      CheckResult(
          id: 'changelog',
          description: 'CHANGELOG.md present',
          status: CheckStatus.pass)
    ];
  }

  Future<List<CheckResult>> _checkSigningConfig(String rootDir) async {
    final keystorePath1 = p.join(rootDir, 'keystore.properties');
    final keystorePath2 = p.join(rootDir, 'key.properties');
    if (!await File(keystorePath1).exists() &&
        !await File(keystorePath2).exists()) {
      return [
        CheckResult(
            id: 'signing',
            description: 'No keystore.properties found',
            status: CheckStatus.fail,
            details: 'Required for release signing')
      ];
    }
    return [
      CheckResult(
          id: 'signing',
          description: 'Release signing config present',
          status: CheckStatus.pass)
    ];
  }
}
