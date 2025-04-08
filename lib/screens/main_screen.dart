import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/providers/integeration_state_provider.dart';
import '../models/integration_state_model.dart';
import 'project_selection_screen.dart';
import 'api_keys_screen.dart';
import 'integration_screen.dart';
import 'completion_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrationState = ref.watch(integrationStateProvider);

    // Based on the current step, show the appropriate screen
    switch (integrationState.currentStep) {
      case IntegrationStep.selectProject:
      case IntegrationStep.validateProject:
        return const ProjectSelectionScreen();

      case IntegrationStep.collectApiKeys:
        return const ApiKeysScreen();

      case IntegrationStep.addPackageDependency:
      case IntegrationStep.runPubGet:
      case IntegrationStep.configureAndroid:
      case IntegrationStep.configureIOS:
      case IntegrationStep.addExampleFile:
        return const IntegrationScreen();

      case IntegrationStep.complete:
        return const CompletionScreen();
    }
  }
}
