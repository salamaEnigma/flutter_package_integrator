import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/providers/integeration_state_provider.dart';
import 'package:package_integrator/providers/integration_process_notifier.dart';
import '../providers/providers.dart';
import '../widgets/step_indicator.dart';

class IntegrationScreen extends ConsumerStatefulWidget {
  const IntegrationScreen({super.key});

  @override
  ConsumerState<IntegrationScreen> createState() => _IntegrationScreenState();
}

class _IntegrationScreenState extends ConsumerState<IntegrationScreen> {
  @override
  void initState() {
    super.initState();
    // Start the integration process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(integrationProcessProvider.notifier).runIntegration(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final integrationState = ref.watch(integrationStateProvider);
    final logMessage = ref.watch(logMessagesProvider);
    final isProcessing = ref.watch(integrationProcessProvider);

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
            Text(
              integrationState.isComplete
                  ? 'Integration Complete!'
                  : 'Integrating Google Maps...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (integrationState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error: ${integrationState.errorMessage}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed:
                          isProcessing
                              ? null
                              : () => ref
                                  .read(integrationProcessProvider.notifier)
                                  .runIntegration(context),
                      child:
                          isProcessing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Retry'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Integration Log',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  logMessage.map((message) {
                                    return Text(
                                      message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    integrationState.isComplete
                        ? () =>
                            ref
                                .read(integrationStateProvider.notifier)
                                .nextStep()
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Next: Complete',
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
