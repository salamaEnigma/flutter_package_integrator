// State providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/models/project_model.dart';
import 'package:package_integrator/providers/service_providers.dart';

final selectedProjectProvider = StateProvider<FlutterProject?>((ref) {
  return null;
});

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
