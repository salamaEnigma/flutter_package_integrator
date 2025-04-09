import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../widgets/permission_dialog.dart';

class ProjectService {
  // Select a Flutter project directory
  Future<String?> selectProjectDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Flutter Project Directory',
    );
    return result;
  }

  // Validate if the selected path is a valid Flutter project
  Future<FlutterProject> validateFlutterProject(String path) async {
    final pubspecFile = File('$path/pubspec.yaml');

    // Check if pubspec.yaml exists
    if (!await pubspecFile.exists()) {
      return FlutterProject(
        path: path,
        isValid: false,
        validationMessage:
            'The selected directory does not contain a pubspec.yaml file.',
      );
    }

    try {
      // Read pubspec.yaml content
      final content = await pubspecFile.readAsString();

      // Check if it's a Flutter project
      if (!content.contains('flutter:') || !content.contains('sdk: flutter')) {
        return FlutterProject(
          path: path,
          isValid: false,
          validationMessage: 'The selected directory is not a Flutter project.',
        );
      }

      // Check if google_maps_flutter is already added
      if (content.contains('google_maps_flutter:')) {
        return FlutterProject(
          path: path,
          isValid: true,
          validationMessage:
              'Google Maps Flutter package is already added to this project.',
        );
      }

      return FlutterProject(path: path, isValid: true);
    } catch (e) {
      return FlutterProject(
        path: path,
        isValid: false,
        validationMessage: 'Error reading pubspec.yaml: ${e.toString()}',
      );
    }
  }

  // Add google_maps_flutter dependency to pubspec.yaml
  Future<bool> addPackageToPubspec(String projectPath) async {
    try {
      final pubspecFile = File('$projectPath/pubspec.yaml');
      String content = await pubspecFile.readAsString();

      // Check if package already exists
      if (content.contains('google_maps_flutter:')) {
        return true; // Already exists
      }

      // Add package with latest version
      final dependenciesIndex = content.indexOf('dependencies:');
      final insertPoint = content.indexOf('\n', dependenciesIndex) + 1;

      content =
          '${content.substring(0, insertPoint)}  google_maps_flutter: ^2.5.0\n${content.substring(insertPoint)}';

      await pubspecFile.writeAsString(content);
      return true;
    } catch (e) {
      log('Error adding package to pubspec: $e');
      return false;
    }
  }

  // Run flutter pub get in the target project
  Future<bool> runFlutterPubGet(
    String projectPath, [
    BuildContext? context,
  ]) async {
    try {
      log('Running flutter pub get in project path: $projectPath');

      // First, verify the path exists and is accessible
      final directory = Directory(projectPath);
      if (!await directory.exists()) {
        log('Project directory does not exist: $projectPath');
        return false;
      }

      // Try to run flutter pub get directly using ProcessResult for better control
      final result = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: projectPath,
        includeParentEnvironment: true,
        runInShell: true,
      );

      log('Command output: ${result.stdout}');

      if (result.exitCode != 0) {
        log('Error running flutter pub get: ${result.stderr}');

        // If it's a permission error, show the dialog if context is available
        if ((result.stderr.toString().contains('Operation not permitted') ||
                result.stderr.toString().contains('Permission denied')) &&
            context != null) {
          log('Permission issue detected. Showing permission dialog...');
          return context.mounted &&
              await _showPermissionDialog(context, projectPath);
        } else {
          log(
            'PERMISSION_DIALOG: Please open Terminal and run the following command:',
          );
          log('PERMISSION_DIALOG: cd "$projectPath" && flutter pub get');
          return false;
        }
      }

      return true;
    } catch (e) {
      log('Exception running flutter pub get: $e');

      // Check if it's a permission error and show dialog
      if ((e.toString().contains('Operation not permitted') ||
              e.toString().contains('Permission denied')) &&
          context != null) {
        log(
          'Permission issue detected from exception. Showing permission dialog...',
        );
        return context.mounted &&
            await _showPermissionDialog(context, projectPath);
      } else {
        log(
          'PERMISSION_DIALOG: Please open Terminal and run the following command:',
        );
        log('PERMISSION_DIALOG: cd "$projectPath" && flutter pub get');
        return false;
      }
    }
  }

  // Show permission dialog and handle user response
  Future<bool> _showPermissionDialog(
    BuildContext context,
    String projectPath,
  ) async {
    // Use a Completer to wait for the dialog result
    final completer = Completer<bool>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PermissionDialog(
            projectPath: projectPath,
            onCancel: () {
              completer.complete(false);
            },
            onResult: (success) {
              completer.complete(success);
            },
          ),
    );

    return completer.future;
  }
}
