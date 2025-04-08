class FlutterProject {
  final String path;
  final bool isValid;
  final String? validationMessage;

  FlutterProject({
    required this.path,
    required this.isValid,
    this.validationMessage,
  });

  FlutterProject copyWith({
    String? path,
    bool? isValid,
    String? validationMessage,
  }) {
    return FlutterProject(
      path: path ?? this.path,
      isValid: isValid ?? this.isValid,
      validationMessage: validationMessage ?? this.validationMessage,
    );
  }
}
