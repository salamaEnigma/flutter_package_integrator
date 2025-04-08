import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
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

// State providers
final selectedProjectProvider = StateProvider<FlutterProject?>((ref) {
  return null;
});

// Note: apiKeysProvider is now replaced by apiKeysNotifierProvider

// Integration process providers
final projectSelectionProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final projectService = ref.read(projectServiceProvider);
  return await projectService.selectProjectDirectory();
});

final projectValidationProvider = FutureProvider.family<FlutterProject, String>(
  (ref, path) async {
    final projectService = ref.read(projectServiceProvider);
    return await projectService.validateFlutterProject(path);
  },
);

final addPackageProvider = FutureProvider.family<bool, String>((
  ref,
  projectPath,
) async {
  final projectService = ref.read(projectServiceProvider);
  return await projectService.addPackageToPubspec(projectPath);
});

final pubGetProvider = FutureProvider.family<bool, String>((
  ref,
  projectPath,
) async {
  final projectService = ref.read(projectServiceProvider);
  return await projectService.runFlutterPubGet(projectPath);
});

// Context-aware pub get provider
final pubGetWithContextProvider =
    Provider.family<Future<bool> Function(), (String, BuildContext)>((
      ref,
      params,
    ) {
      final projectPath = params.$1;
      final context = params.$2;
      final projectService = ref.read(projectServiceProvider);

      return () async {
        return await projectService.runFlutterPubGet(projectPath, context);
      };
    });

final configureAndroidProvider =
    FutureProvider.family<bool, ({String projectPath, String apiKey})>((
      ref,
      params,
    ) async {
      final platformConfigService = ref.read(platformConfigServiceProvider);
      return await platformConfigService.configureAndroid(
        params.projectPath,
        params.apiKey,
      );
    });

final configureIOSProvider =
    FutureProvider.family<bool, ({String projectPath, String apiKey})>((
      ref,
      params,
    ) async {
      final platformConfigService = ref.read(platformConfigServiceProvider);
      return await platformConfigService.configureIOS(
        params.projectPath,
        params.apiKey,
      );
    });

final addExampleProvider = FutureProvider.family<bool, String>((
  ref,
  projectPath,
) async {
  final exampleService = ref.read(exampleServiceProvider);
  final addExample = await exampleService.addExampleFile(projectPath);
  if (addExample) {
    await exampleService.updateMainDart(projectPath);
  }
  return addExample;
});

final logMessagesProvider = StateProvider.autoDispose<List<String>>((ref) {
  return [];
});
