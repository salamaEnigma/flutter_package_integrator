import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_integrator/models/integration_state_model.dart';
import 'package:package_integrator/providers/integration_progress_providers.dart';
import 'package:package_integrator/providers/service_providers.dart';

final integrationStateProvider =
    NotifierProvider<IntegrationStateNotifier, IntegrationState>(
      IntegrationStateNotifier.new,
    );

class IntegrationStateNotifier extends Notifier<IntegrationState> {
  @override
  IntegrationState build() {
    return IntegrationState(currentStep: IntegrationStep.selectProject);
  }

  /// Completes the integration process and sets the state to complete
  void completeIntegration() {
    state = state.copyWith(
      inProgress: false,
      currentStep: IntegrationStep.complete,
      lastCompletedStep: state.currentStep,
    );
  }

  /// Sets an error message in the state
  void setError(String errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }

  /// Advances to the next step in the integration process
  void nextStep() {
    log("Current $state");
    final nextStep =
        IntegrationStep.values[(state.currentStep.index + 1) %
            IntegrationStep.values.length];

    log("Next step $nextStep");

    state = IntegrationState(
      currentStep: nextStep,
      lastCompletedStep: state.currentStep,
      inProgress: false,
      errorMessage: null,
    );
  }

  /// Go back to the previous step
  void goBack() {
    final prevStepIndex = state.currentStep.index - 1;
    if (prevStepIndex >= 0) {
      final prevStep = IntegrationStep.values[prevStepIndex];
      state = state.copyWith(currentStep: prevStep);
    }
  }

  /// Updates various aspects of the integration state
  void updateState({
    IntegrationStep? currentStep,
    IntegrationStep? lastCompletedStep,
    bool? inProgress,
    String? errorMessage,
  }) {
    state = state.copyWith(
      currentStep: currentStep,
      lastCompletedStep: lastCompletedStep,
      inProgress: inProgress,
      errorMessage: errorMessage,
    );
  }

  /// Sets the in-progress flag directly
  void setInProgress(bool inProgress) {
    state = state.copyWith(inProgress: inProgress);
  }

  /// Completely resets the integration state
  void reset() {
    state = IntegrationState(currentStep: IntegrationStep.selectProject);
  }

  /// Handles project selection, validation, and state updates
  Future<void> selectAndValidateProject() async {
    try {
      setInProgress(true);

      // Get project path from service
      final projectService = ref.read(projectServiceProvider);
      final projectPath = await projectService.selectProjectDirectory();

      if (projectPath != null) {
        // Validate the selected project
        final validationResult = await ref.read(
          projectValidationProvider(projectPath).future,
        );

        // Update the selected project state
        ref.read(selectedProjectProvider.notifier).state = validationResult;

        // Move to next step if valid
        if (validationResult.isValid) {
          nextStep();
        } else {
          setError(validationResult.validationMessage ?? "Invalid project");
        }
      }
    } catch (e) {
      log('Error selecting project: $e');
      setError("Error selecting project: $e");
    } finally {
      setInProgress(false);
    }
  }
}
