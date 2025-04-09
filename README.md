# Google Maps Package Integrator

A Flutter tool that helps you integrate Google Maps into your Flutter applications.

## Features

- Automatically adds the Google Maps Flutter plugin to your existing Flutter project
- Configures the Android and iOS platforms for Google Maps
- Adds a working example of Google Maps integration
- Streamlines the setup process that would otherwise require manual editing of multiple files

## Requirements

- Flutter SDK 2.0.0 or higher
- Google Maps API key for both Android and iOS platforms
- iOS 13.0+ for iOS deployment
- Android API level 21+ for Android deployment

## Getting Started

1. **Get Google Maps API Keys**:
   - Go to the [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Maps SDK for Android and/or iOS
   - Create API keys for each platform (Android and iOS)
   - See [Google Maps Platform Documentation](https://developers.google.com/maps/documentation/android-sdk/get-api-key) for detailed instructions

2. **Run the integrator**:
   - Launch the app
   - Select your Flutter project
   - Enter your Google Maps API keys
   - Let the app configure your project

3. **After integration**:
   - Open your project in your preferred IDE
   - Run `flutter pub get` to ensure all dependencies are updated
   - The example can be found at `lib/google_maps_example.dart`
   - Your `main.dart` file will be updated with a button to access the example

## How It Works

The integrator performs the following steps:

### Android Configuration:
- Adds the Google Maps dependency to your pubspec.yaml
- Updates AndroidManifest.xml with the required permissions and API key metadata
- Sets minimum SDK version to 21

### iOS Configuration:
- Updates Info.plist with required permissions and API key
- Modifies AppDelegate.swift or AppDelegate.m to initialize Google Maps
- Ensures minimum iOS version is set to 13.0 in Podfile

## Troubleshooting

- **iOS Build Fails**: Make sure you have CocoaPods installed and run `pod install` in the iOS folder
- **Android Build Fails**: Verify your minSdkVersion is set to 21 or higher
- **Maps Not Displaying**: Check that your API keys are correct and have the appropriate restrictions
- **Location Not Working**: Ensure location permissions are properly configured in your app

## Resources

- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Documentation](https://docs.flutter.dev/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
