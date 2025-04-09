import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/providers/api_keys_notifier.dart';
import 'package:package_integrator/providers/integration_state_notifier.dart';
import '../widgets/step_indicator.dart';

class ApiKeysScreen extends ConsumerWidget {
  const ApiKeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrationState = ref.watch(integrationStateProvider);
    final apiKeys = ref.watch(apiKeysNotifierProvider);
    final isProcessing = integrationState.inProgress;

    // Controllers for text fields
    final androidController = TextEditingController(
      text: apiKeys.androidApiKey,
    );
    final iosController = TextEditingController(text: apiKeys.iosApiKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Package Integrator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isProcessing ? null : () => _goBack(ref),
        ),
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
              'Enter Google Maps API Keys',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'You need to provide Google Maps API keys for both Android and iOS platforms. '
              'These keys will be added to the platform-specific configuration files.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _openApiKeyHelp(context),
              child: const Text(
                'How to get API keys →',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
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
                      'Android API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: androidController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Android API Key',
                      ),
                      onChanged:
                          (value) => ref
                              .read(apiKeysNotifierProvider.notifier)
                              .updateAndroidApiKey(value),
                      enabled: !isProcessing,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'iOS API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: iosController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter iOS API Key',
                      ),
                      onChanged:
                          (value) => ref
                              .read(apiKeysNotifierProvider.notifier)
                              .updateIOSApiKey(value),
                      enabled: !isProcessing,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: If you want to use the same API key for both platforms, enter it in both fields.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            if (integrationState.hasError) ...[
              const SizedBox(height: 16),
              Text(
                integrationState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isProcessing
                            ? null
                            : () =>
                                ref
                                    .read(apiKeysNotifierProvider.notifier)
                                    .skipApiKeys(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Skip this step',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isProcessing
                            ? null
                            : (ref
                                    .read(apiKeysNotifierProvider.notifier)
                                    .canProceed()
                                ? () =>
                                    ref
                                        .read(apiKeysNotifierProvider.notifier)
                                        .saveAndProceed()
                                : null),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Next: Integration',
                      style: TextStyle(fontSize: 16),
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

  void _goBack(WidgetRef ref) {
    ref.read(integrationStateProvider.notifier).goBack();
  }

  void _openApiKeyHelp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('How to Get Google Maps API Keys'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1. Go to the Google Cloud Console',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Visit https://console.cloud.google.com and sign in with your Google account.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2. Create a new project or select an existing one',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'From the project dropdown, create a new project or select an existing one.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3. Enable the Maps SDK for Android and/or iOS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Go to APIs & Services > Library and enable the Maps SDK for Android and/or Maps SDK for iOS.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '4. Create credentials',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Go to APIs & Services > Credentials and click "Create credentials" > API key.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '5. Restrict the API key (recommended)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'For security, restrict the API key to your app\'s package name and SHA-1 signing certificate for Android, and bundle identifier for iOS.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
