class ApiKeys {
  final String? androidApiKey;
  final String? iosApiKey;

  const ApiKeys({this.androidApiKey, this.iosApiKey});

  bool get isComplete => androidApiKey != null && iosApiKey != null;

  bool get hasAndroidKey => androidApiKey != null && androidApiKey!.isNotEmpty;

  bool get hasIOSKey => iosApiKey != null && iosApiKey!.isNotEmpty;

  ApiKeys copyWith({String? androidApiKey, String? iosApiKey}) {
    return ApiKeys(
      androidApiKey: androidApiKey ?? this.androidApiKey,
      iosApiKey: iosApiKey ?? this.iosApiKey,
    );
  }
}
