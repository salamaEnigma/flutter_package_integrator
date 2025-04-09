import 'dart:developer';
import 'dart:io';

class PlatformConfigService {
  // Configure Android platform for Google Maps
  Future<bool> configureAndroid(String projectPath, String apiKey) async {
    try {
      // Main manifest
      final manifestPath =
          '$projectPath/android/app/src/main/AndroidManifest.xml';
      final manifestFile = File(manifestPath);

      if (!await manifestFile.exists()) {
        log('AndroidManifest.xml not found at path: $manifestPath');
        return false;
      }

      String content = await manifestFile.readAsString();

      // Check if already configured
      if (!content.contains('com.google.android.geo.API_KEY')) {
        // Find application tag
        final applicationStart = content.indexOf('<application');
        if (applicationStart == -1) {
          log('Application tag not found in AndroidManifest.xml');
          return false;
        }

        final applicationTagEnd = content.indexOf('>', applicationStart) + 1;

        // Insert meta-data after application tag opening
        content =
            '${content.substring(0, applicationTagEnd)}\n        <meta-data\n            android:name="com.google.android.geo.API_KEY"\n            android:value="$apiKey"/>${content.substring(applicationTagEnd)}';

        // Add permissions if not present
        if (!content.contains('ACCESS_FINE_LOCATION')) {
          final manifestTagEnd =
              content.indexOf('>', content.indexOf('<manifest')) + 1;
          content =
              '${content.substring(0, manifestTagEnd)}\n    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>\n    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>${content.substring(manifestTagEnd)}';
        }

        await manifestFile.writeAsString(content);
      }

      return true;
    } catch (e) {
      log('Error configuring Android: $e');
      return false;
    }
  }

  // Configure iOS platform for Google Maps
  Future<bool> configureIOS(String projectPath, String apiKey) async {
    try {
      bool delegateUpdated = await _updateAppDelegate(projectPath, apiKey);
      return delegateUpdated;
    } catch (e) {
      log('Error configuring iOS: $e');
      return false;
    }
  }

  // Update AppDelegate files (Swift or Objective-C)
  Future<bool> _updateAppDelegate(String projectPath, String apiKey) async {
    try {
      // Try Swift first
      final swiftPath = '$projectPath/ios/Runner/AppDelegate.swift';
      final swiftFile = File(swiftPath);

      if (await swiftFile.exists()) {
        String content = await swiftFile.readAsString();

        // Check if already configured
        if (!content.contains('GMSServices.provideAPIKey')) {
          // Find import section
          if (!content.contains('import GoogleMaps')) {
            final lastImport = content.lastIndexOf('import');
            final endOfLine = content.indexOf('\n', lastImport);
            content =
                '${content.substring(0, endOfLine + 1)}import GoogleMaps\n${content.substring(endOfLine + 1)}';
          }

          // Add API key initialization
          final didFinishLaunchingIndex = content.indexOf(
            'didFinishLaunchingWithOptions',
          );
          if (didFinishLaunchingIndex != -1) {
            final openBraceIndex = content.indexOf(
              '{',
              didFinishLaunchingIndex,
            );
            content =
                '${content.substring(0, openBraceIndex + 1)}\n    GMSServices.provideAPIKey("$apiKey")${content.substring(openBraceIndex + 1)}';
          }

          await swiftFile.writeAsString(content);
        }
        return true;
      }

      // If Swift not found, try Objective-C
      final objcPath = '$projectPath/ios/Runner/AppDelegate.m';
      final objcFile = File(objcPath);

      if (await objcFile.exists()) {
        String content = await objcFile.readAsString();

        // Check if already configured
        if (!content.contains('[GMSServices provideAPIKey:')) {
          // Find import section
          if (!content.contains('#import <GoogleMaps/GoogleMaps.h>')) {
            final lastImport = content.lastIndexOf('#import');
            final endOfLine = content.indexOf('\n', lastImport);
            content =
                '${content.substring(0, endOfLine + 1)}#import <GoogleMaps/GoogleMaps.h>\n${content.substring(endOfLine + 1)}';
          }

          // Add API key initialization
          final didFinishLaunchingIndex = content.indexOf(
            'didFinishLaunchingWithOptions',
          );
          if (didFinishLaunchingIndex != -1) {
            final openBraceIndex = content.indexOf(
              '{',
              didFinishLaunchingIndex,
            );
            content =
                '${content.substring(0, openBraceIndex + 1)}\n  [GMSServices provideAPIKey:@"$apiKey"];${content.substring(openBraceIndex + 1)}';
          }

          await objcFile.writeAsString(content);
        }
        return true;
      }

      log('Neither AppDelegate.swift nor AppDelegate.m found');
      return false;
    } catch (e) {
      log('Error updating AppDelegate: $e');
      return false;
    }
  }

  //   // Update Info.plist file
  //   Future<bool> _updateInfoPlist(String projectPath, String apiKey) async {
  //     try {
  //       final plistPath = '$projectPath/ios/Runner/Info.plist';
  //       final plistFile = File(plistPath);

  //       if (!await plistFile.exists()) {
  //         log('Info.plist not found at path: $plistPath');
  //         return false;
  //       }

  //       String content = await plistFile.readAsString();

  //       // Check if already configured
  //       if (!content.contains('GMSApiKey')) {
  //         // Find end of dict tag for insertion
  //         final dictCloseIndex = content.lastIndexOf('</dict>');

  //         if (dictCloseIndex == -1) {
  //           log('Closing dict tag not found in Info.plist');
  //           return false;
  //         }

  //         // Add required keys - Note: io.flutter.embedded_views_preview is no longer needed
  //         String insertion = '''
  // 	<key>NSLocationWhenInUseUsageDescription</key>
  // 	<string>This app needs access to location when open.</string>
  // 	<key>NSLocationAlwaysUsageDescription</key>
  // 	<string>This app needs access to location when in the background.</string>
  // 	<key>GMSApiKey</key>
  // 	<string>$apiKey</string>
  // ''';

  //         content =
  //             content.substring(0, dictCloseIndex) +
  //             insertion +
  //             content.substring(dictCloseIndex);

  //         await plistFile.writeAsString(content);
  //       }

  //       return true;
  //     } catch (e) {
  //       log('Error updating Info.plist: $e');
  //       return false;
  //     }
  //   }
}
