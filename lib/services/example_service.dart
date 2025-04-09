import 'dart:developer';
import 'dart:io';

class ExampleService {
  // Add example Google Maps widget to the target project
  Future<bool> addExampleFile(String projectPath) async {
    try {
      final exampleFilePath = '$projectPath/lib/google_maps_example.dart';
      final exampleFile = File(exampleFilePath);

      await exampleFile.writeAsString(_generateExampleCode());

      return true;
    } catch (e) {
      log('Error adding example file: $e');
      return false;
    }
  }

  // Generate example code for Google Maps widget
  String _generateExampleCode() {
    return '''
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsExample extends StatefulWidget {
  const GoogleMapsExample({Key? key}) : super(key: key);

  @override
  State<GoogleMapsExample> createState() => _GoogleMapsExampleState();
}

class _GoogleMapsExampleState extends State<GoogleMapsExample> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(37.7749, -122.4194); // San Francisco
  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
''';
  }

  // Update main.dart to directly use GoogleMapsExample
  Future<bool> updateMainDart(String projectPath) async {
    try {
      final mainFilePath = '$projectPath/lib/main.dart';
      final mainFile = File(mainFilePath);

      if (!await mainFile.exists()) {
        log('main.dart not found at path: $mainFilePath');
        return false;
      }

      // Create a completely new main.dart file with just the GoogleMapsExample
      final newMainContent = '''
import 'package:flutter/material.dart';
import 'google_maps_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GoogleMapsExample(),
    );
  }
}
''';

      // Replace the entire file content
      await mainFile.writeAsString(newMainContent);
      log('Replaced main.dart with simplified GoogleMapsExample version');

      return true;
    } catch (e) {
      log('Error updating main.dart: $e');
      return false;
    }
  }
}
