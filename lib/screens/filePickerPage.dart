import 'package:flutter/material.dart';
import 'package:velocity/models/archive/conversionListModel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:velocity/screens/archive/fileDetailsPage.dart';

class ConversionPage extends StatelessWidget {
  const ConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> getAllowedExtensions(String title) {
      if (title.contains(' to ')) {
        return [title.split(' to ').first.toLowerCase()];
      }
      return []; // Fallback if the title doesn't match the pattern
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("File Converter"),
        centerTitle: true,
        leading: BackButton(
          color: Colors.grey,
          onPressed: () {
            print("backbutton pressed woo");
            //Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Select Files to Convert",style: TextStyle(fontSize: 24, )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Convert documents, images, and audio seamlessly.",style: TextStyle(fontSize: 15)),
            ),
            SizedBox(height: 70),
            // Use Expanded so the widget dynamically fills the remaining vertical/horizontal space
Expanded(
  child: RepaintBoundary(
    child: GestureDetector(
      onTap: () async {
        print("file selection thing clicked");
        final allowedExts = getAllowedExtensions("png to jpeg");
        final targetExt = getTargetExtension("png to jpeg");

        FilePickerResult? result = await FilePicker.pickFiles(
          type: allowedExts.isNotEmpty ? FileType.custom : FileType.any,
          allowedExtensions: allowedExts.isNotEmpty ? allowedExts : null,
        );

        if (result != null) {
          List<PlatformFile> selectedFiles = result.files;

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FileDetailsPage(
                  files: selectedFiles,
                  targetFormat: targetExt,
                ),
              ),
            );
          }
        } else {
          print("User canceled the picker");
        }
      },
      child: Container(
        // Generous, uniform margin away from the screen borders
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          // Darker background matching your UI screenshot
          color: const Color(0xFF121212), 
          borderRadius: BorderRadius.circular(16),
        ),
        // Padding inside the outer card container
        padding: const EdgeInsets.all(16.0),
        child: DottedBorder(
          color: Colors.grey.withOpacity(0.3), // Subdued dotted border color
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(16),
          child: Container(
            // Forces the inner container to expand and match its parent boundaries completely
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Sleek circular badge wrapper for the icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF005A53), // Teal circle background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.file_upload,
                      size: 28, 
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Bold title text
                  const Text(
                    'Tap to browse',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 3. Subtitle description
                  Text(
                    'or drag and drop files here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. "Multiple files supported" Chip pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.layers_outlined,
                          size: 14,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Multiple files supported',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}

String getTargetExtension(String title) {
  if (title.contains(' to ')) {
    return title.split(' to ').last.toLowerCase().trim();
  }
  return 'unknown';
}
