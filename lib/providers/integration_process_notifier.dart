import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/providers/integration_progress_providers.dart';
import 'package:package_integrator/providers/integration_state_notifier.dart';
import 'package:package_integrator/providers/api_keys_notifier.dart';
import 'package:package_integrator/models/integration_state_model.dart';

final integrationProcessProvider =
    NotifierProvider<IntegrationProcessNotifier, bool>(
      IntegrationProcessNotifier.new,
    );

class IntegrationProcessNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Initial state - not processing
    return false;
  }

  /// Run the entire integration process
  Future<void> runIntegration(BuildContext context) async {
    if (state) return; // Already processing

    state = true; // Set processing to true

    try {
      final integrationNotifier = ref.read(integrationStateProvider.notifier);
      integrationNotifier.setInProgress(true);

      // Get project path
      final project = ref.read(selectedProjectProvider);
      if (project == null || !project.isValid) {
        throw Exception("Invalid project selected");
      }

      final projectPath = project.path;
      final apiKeys = ref.read(apiKeysNotifierProvider);

      // Add logs
      _addLog("Starting integration for project: $projectPath");

      // Step 1: Add package dependency
      integrationNotifier.updateState(
        currentStep: IntegrationStep.addPackageDependency,
      );
      final packageAdded = await ref.read(
        addPackageProvider(projectPath).future,
      );
      if (!packageAdded) {
        throw Exception("Failed to add package dependency");
      }
      _addLog("✓ Added package dependency");

      // Step 2: Run pub get
      integrationNotifier.updateState(currentStep: IntegrationStep.runPubGet);
      final pubGetFunction = ref.read(
        pubGetWithContextProvider((projectPath, context)),
      );
      final pubGetSuccess = await pubGetFunction();
      if (!pubGetSuccess) {
        throw Exception("Failed to run flutter pub get");
      }
      _addLog("✓ Flutter pub get completed");

      // Step 3: Configure Android (if API key provided)
      if (apiKeys.hasAndroidKey) {
        integrationNotifier.updateState(
          currentStep: IntegrationStep.configureAndroid,
        );
        final androidConfigured = await ref.read(
          configureAndroidProvider((
            projectPath: projectPath,
            apiKey: apiKeys.androidApiKey!,
          )).future,
        );
        if (!androidConfigured) {
          throw Exception("Failed to configure Android");
        }
        _addLog("✓ Android platform configured");
      } else {
        _addLog("⚠️ Skipping Android configuration (no API key)");
      }

      // Step 4: Configure iOS (if API key provided)
      if (apiKeys.hasIOSKey) {
        integrationNotifier.updateState(
          currentStep: IntegrationStep.configureIOS,
        );
        final iosConfigured = await ref.read(
          configureIOSProvider((
            projectPath: projectPath,
            apiKey: apiKeys.iosApiKey!,
          )).future,
        );
        if (!iosConfigured) {
          throw Exception("Failed to configure iOS");
        }
        _addLog("✓ iOS platform configured");
      } else {
        _addLog("⚠️ Skipping iOS configuration (no API key)");
      }

      // Step 5: Add example file
      integrationNotifier.updateState(
        currentStep: IntegrationStep.addExampleFile,
      );
      final exampleAdded = await ref.read(
        addExampleProvider(projectPath).future,
      );
      if (!exampleAdded) {
        throw Exception("Failed to add example file");
      }
      _addLog("✓ Added example file and updated main.dart");

      // Complete integration
      _addLog("✓ Integration completed successfully!");
      integrationNotifier.completeIntegration();
    } catch (e) {
      log("Integration error: $e");
      ref.read(integrationStateProvider.notifier).setError(e.toString());
      _addLog("❌ Error: $e");
    } finally {
      ref.read(integrationStateProvider.notifier).setInProgress(false);
      state = false; // Set processing to false
    }
  }

  void _addLog(String message) {
    final currentLogs = ref.read(logMessagesProvider);
    ref.read(logMessagesProvider.notifier).state = [...currentLogs, message];
  }
}
