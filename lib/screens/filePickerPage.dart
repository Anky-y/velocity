import 'package:flutter/material.dart';
import 'package:velocity/models/archive/conversionListModel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:velocity/models/fileOperationModel.dart';
import 'package:velocity/screens/fileDetailsPage.dart';
import 'package:velocity/screens/homePage.dart';
import 'package:velocity/data/format_registry.dart';

class FilePickerPage extends StatelessWidget {
  const FilePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Converter".toUpperCase()),
        centerTitle: true,
        leading: BackButton(
          color: Colors.grey,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "Select Files to Convert",

                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Convert documents, images, and audio seamlessly.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            // Use Expanded so the widget dynamically fills the remaining vertical/horizontal space
            Expanded(
              child: RepaintBoundary(
                child: GestureDetector(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.pickFiles(
                      type: FileType.any,
                    );

                    if (result != null) {
                      List<FileOperationItem> operations = [];
                      for (final file in result.files) {
                        final extension = (file.extension ?? "").toLowerCase();
                        final supportedTargets = FormatRegistry.getTargets(
                          extension,
                        );
                        if (supportedTargets.isEmpty) {
                          continue;
                        }
                        operations.add(
                          FileOperationItem(
                            id: file.identifier ?? file.name,
                            file: file,
                            originalExtension: extension,
                            availableTargetExtensions: supportedTargets,
                          ),
                        );
                      }
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FileDetailsPage(operations: operations),
                          ),
                        );
                      }
                    } else {
                      print("User canceled the picker");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      // Darker background matching your UI screenshot
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // Padding inside the outer card container
                    padding: const EdgeInsets.all(16.0),
                    child: DottedBorder(
                      color: Theme.of(context).colorScheme.outline,
                      strokeWidth: 1.5,
                      dashPattern: const [6, 4],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(16),
                      child: Container(
                        // Forces the inner container to expand and match its parent boundaries completely
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          // color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. Sleek circular badge wrapper for the icon
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(
                                    0xFF005A53,
                                  ), // Teal circle background
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
                              Text(
                                'Tap to browse',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              // 3. Subtitle description
                              Text(
                                'or drag and drop files here',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 24),

                              // 4. "Multiple files supported" Chip pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.layers_outlined,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Multiple files supported',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
      bottomNavigationBar: bottomNavBar(),
    );
  }
}
