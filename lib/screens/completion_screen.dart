import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:package_integrator/providers/api_keys_notifier.dart';
import 'package:package_integrator/providers/integration_progress_providers.dart';
import 'package:package_integrator/providers/integration_state_notifier.dart';
import '../widgets/step_indicator.dart';

class CompletionScreen extends ConsumerWidget {
  const CompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrationState = ref.watch(integrationStateProvider);
    final selectedProject = ref.watch(selectedProjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Package Integrator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
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
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Integration Complete!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Google Maps has been successfully integrated into your Flutter project.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Steps',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNextStepItem(
                          '1',
                          'Open your project in your IDE',
                          'Navigate to: ${selectedProject?.path ?? 'your project'}',
                        ),
                        const SizedBox(height: 16),
                        _buildNextStepItem(
                          '2',
                          'Explore the example widget',
                          'Check lib/google_maps_example.dart to see a working example.',
                        ),
                        const SizedBox(height: 16),
                        _buildNextStepItem(
                          '3',
                          'Run your app on a physical device or emulator',
                          'Make sure location services are enabled.',
                        ),
                        const SizedBox(height: 16),
                        _buildNextStepItem(
                          '4',
                          'Customize the map for your needs',
                          'Add markers, change styles, and integrate with your app.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Thank you for using the Google Maps Package Integrator!',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resetIntegration(ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Start New Integration',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _exitApp(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueGrey,
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  void _resetIntegration(WidgetRef ref) {
    // Reset all state
    ref.read(selectedProjectProvider.notifier).state = null;
    ref.read(apiKeysNotifierProvider.notifier).clearKeys();
    ref.read(integrationStateProvider.notifier).reset();
  }

  void _exitApp(BuildContext context) {
    // Platform-specific exit
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop();
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      exit(0);
    }
  }
}
