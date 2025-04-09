import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/providers/integration_progress_providers.dart';
import 'package:package_integrator/providers/integration_state_notifier.dart';
import '../widgets/step_indicator.dart';

class ProjectSelectionScreen extends ConsumerWidget {
  const ProjectSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrationState = ref.watch(integrationStateProvider);
    final selectedProject = ref.watch(selectedProjectProvider);
    final isProcessing = integrationState.inProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Package Integrator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepIndicator(
              currentStep: integrationState.currentStep,
              lastCompletedStep: integrationState.lastCompletedStep,
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Your Flutter Project',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This tool will help you integrate Google Maps into your Flutter project. '
              'It will add the necessary dependencies, configure platform-specific settings, '
              'and add a working example.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              selectedProject?.path ?? 'No project selected',
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () =>
                                      ref
                                          .read(
                                            integrationStateProvider.notifier,
                                          )
                                          .selectAndValidateProject(),
                          child:
                              isProcessing
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Browse'),
                        ),
                      ],
                    ),
                    if (selectedProject != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            selectedProject.isValid
                                ? Icons.check_circle
                                : Icons.warning,
                            color:
                                selectedProject.isValid
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedProject.validationMessage ??
                                  'Valid Flutter project',
                              style: TextStyle(
                                color:
                                    selectedProject.isValid
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (integrationState.hasError) ...[
                      const SizedBox(height: 16),
                      Text(
                        integrationState.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedProject?.isValid == true && !isProcessing
                        ? () =>
                            ref
                                .read(integrationStateProvider.notifier)
                                .nextStep()
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Next: API Keys',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
