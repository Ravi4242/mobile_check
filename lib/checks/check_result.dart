enum CheckStatus { pass, warn, fail }

class CheckResult {
  final String id;
  final String description;
  final CheckStatus status;
  final String? details;

  CheckResult({
    required this.id,
    required this.description,
    required this.status,
    this.details,
  });

  String get emoji => switch (status) {
    CheckStatus.pass => '✅',
    CheckStatus.warn => '⚠️',
    CheckStatus.fail => '❌',
  };

  @override
  String toString() => '$emoji [$id] $description${details != null ? '\n  $details' : ''}';
}
