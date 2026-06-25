import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileDetailsPage extends StatelessWidget {
  final List<PlatformFile> files;
  final String targetFormat; // e.g., "wav" or "mp3"

  const FileDetailsPage({
    super.key, 
    required this.files,
    required this.targetFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Convert to ${targetFormat.toUpperCase()}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Target Format: $targetFormat"),
            Text("Total Files Loaded: ${files.length}"),
            const SizedBox(height: 20),
            // You can implement your custom design/list builder here!
            ElevatedButton(
              onPressed: () {
                // Your conversion logic invocation will go here
              },
              child: const Text("Start Conversion"),
            ),
          ],
        ),
      ),
    );
  }
}