import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/project_service.dart';
import '../services/platform_config_service.dart';
import '../services/example_service.dart';

// Service providers
final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

final platformConfigServiceProvider = Provider<PlatformConfigService>((ref) {
  return PlatformConfigService();
});

final exampleServiceProvider = Provider<ExampleService>((ref) {
  return ExampleService();
});
