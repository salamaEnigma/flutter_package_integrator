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
      final plistPath = '$projectPath/ios/Runner/Info.plist';
      final plistFile = File(plistPath);

      if (!await plistFile.exists()) {
        log('Info.plist not found at path: $plistPath');
        return false;
      }

      String content = await plistFile.readAsString();

      // Check if already configured
      if (!content.contains('io.flutter.embedded_views_preview')) {
        // Find end of dict tag for insertion
        final dictCloseIndex = content.lastIndexOf('</dict>');

        if (dictCloseIndex == -1) {
          log('Closing dict tag not found in Info.plist');
          return false;
        }

        // Add required keys
        String insertion = '''
	<key>io.flutter.embedded_views_preview</key>
	<true/>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>This app needs access to location when open.</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>This app needs access to location when in the background.</string>
	<key>GMSApiKey</key>
	<string>$apiKey</string>
''';

        content =
            content.substring(0, dictCloseIndex) +
            insertion +
            content.substring(dictCloseIndex);

        await plistFile.writeAsString(content);
      }

      return true;
    } catch (e) {
      log('Error configuring iOS: $e');
      return false;
    }
  }
}
