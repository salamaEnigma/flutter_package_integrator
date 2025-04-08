enum IntegrationStep {
  selectProject,
  validateProject,
  collectApiKeys,
  addPackageDependency,
  runPubGet,
  configureAndroid,
  configureIOS,
  addExampleFile,
  complete,
}

class IntegrationState {
  final IntegrationStep currentStep;
  final IntegrationStep? lastCompletedStep;
  final bool inProgress;
  final String? errorMessage;

  bool get isComplete => currentStep == IntegrationStep.complete && !inProgress;

  bool get hasError => errorMessage != null;

  IntegrationState({
    required this.currentStep,
    this.lastCompletedStep,
    this.inProgress = false,
    this.errorMessage,
  });

  IntegrationState copyWith({
    IntegrationStep? currentStep,
    IntegrationStep? lastCompletedStep,
    bool? inProgress,
    String? errorMessage,
  }) {
    return IntegrationState(
      currentStep: currentStep ?? this.currentStep,
      lastCompletedStep: lastCompletedStep ?? this.lastCompletedStep,
      inProgress: inProgress ?? this.inProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return "Current Step $currentStep";
  }
}
