import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PermissionDialog extends StatelessWidget {
  final String projectPath;
  final VoidCallback onCancel;
  final Function(bool) onResult;

  const PermissionDialog({
    super.key,
    required this.projectPath,
    required this.onCancel,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text('Permission Required'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Google Maps Package Integrator needs permission to access the project directory:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              projectPath,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'How would you like to proceed?',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handleManualExecution(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text('Open Terminal', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _handleManualExecution(BuildContext context) async {
    // Show instructions dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildInstructionsDialog(context),
    );
  }

  Widget _buildInstructionsDialog(BuildContext context) {
    // Create a single combined command
    final combinedCommand = 'cd "$projectPath" && flutter pub get';

    return AlertDialog(
      title: Text('Terminal Instructions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please run the following command in Terminal:',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: _CopyableCommandWidget(command: combinedCommand),
          ),
          SizedBox(height: 12),
          Text(
            'After the command completes successfully, return here and click "Done".',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Try to open Terminal with the command
            _openTerminal();
          },
          child: Text('Open Terminal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Assume command was run successfully
            onResult(true);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Done', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _openTerminal() async {
    try {
      // Use a single combined command for all platforms
      final combinedCommand = 'cd "$projectPath" && flutter pub get';

      if (Platform.isMacOS) {
        // Use the AppleScript approach for macOS
        final escapedPath = projectPath.replaceAll('"', '\\"');
        await Process.run('osascript', [
          '-e',
          'tell application "Terminal" to do script "cd \\"$escapedPath\\" && flutter pub get"',
          '-e',
          'tell application "Terminal" to activate',
        ]);
      } else if (Platform.isLinux) {
        // For Linux, use the shell to open the terminal
        final escapedPath = projectPath.replaceAll('"', '\\"');
        await Process.run('sh', [
          '-c',
          'gnome-terminal -- bash -c "cd \\"$escapedPath\\" && flutter pub get; exec bash"',
        ]);
      } else if (Platform.isWindows) {
        // For Windows, use cmd to open a new command prompt
        await Process.run('cmd', ['/c', 'start', 'cmd', '/k', combinedCommand]);
      }
    } catch (e) {
      debugPrint('Error opening terminal: $e');
    }
  }
}

// Widget for copyable command with copy button
class _CopyableCommandWidget extends StatelessWidget {
  final String command;

  const _CopyableCommandWidget({required this.command});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            command,
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy, color: Colors.white, size: 16),
          tooltip: 'Copy to clipboard',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: command));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Command copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}
