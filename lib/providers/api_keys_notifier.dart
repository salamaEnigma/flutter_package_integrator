import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/models/api_key_model.dart';
import 'package:package_integrator/providers/integeration_state_provider.dart';

final apiKeysNotifierProvider = NotifierProvider<ApiKeysNotifier, ApiKeys>(
  ApiKeysNotifier.new,
);

class ApiKeysNotifier extends Notifier<ApiKeys> {
  @override
  ApiKeys build() {
    return ApiKeys();
  }

  /// Update the Android API Key
  void updateAndroidApiKey(String value) {
    state = state.copyWith(androidApiKey: value.trim());
  }

  /// Update the iOS API Key
  void updateIOSApiKey(String value) {
    state = state.copyWith(iosApiKey: value.trim());
  }

  /// Check if we can proceed to the next step
  bool canProceed() {
    return state.hasAndroidKey || state.hasIOSKey;
  }

  /// Skip API keys and proceed to next step
  void skipApiKeys() {
    ref.read(integrationStateProvider.notifier).nextStep();
  }

  /// Save API keys and proceed to next step
  void saveAndProceed() {
    if (canProceed()) {
      ref.read(integrationStateProvider.notifier).nextStep();
    }
  }

  /// Clear all API keys
  void clearKeys() {
    state = ApiKeys();
  }
}
