import 'package:flutter/material.dart';
import 'package:velocity/models/conversionListModel.dart';
import 'package:dotted_border/dotted_border.dart';

class ConversionPage extends StatelessWidget {
  const ConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final option =
        ModalRoute.of(context)!.settings.arguments as ConversionOption;

    return Scaffold(
      appBar: AppBar(title: Text(option.title)),
      body: Center(
        child: RepaintBoundary(
          child: GestureDetector(
            onTap: () {
              print("file selection thing clicked");
            },
            child: Container(
              margin: const EdgeInsets.all(10.0),
              width: 250.0,
              height: 280.0,
              decoration: BoxDecoration(
                color: const Color.fromARGB(235, 255, 255, 255),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: DottedBorder(
                  color: const Color.fromARGB(255, 188, 188, 188), // Border color
                  strokeWidth: 2, // Border thickness
                  dashPattern:const [4, 4],
                  borderType: BorderType.RRect, // Rounded rectangle border
                  radius: const Radius.circular(12), // Border corner radius
                  child: Container(
                    height: 230,
                    width: 200,
                    color: Colors.transparent,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // Shrinks column height to fit its children
                        children: [
                          // 1. File upload icon added as the first element
                          const Icon(
                            Icons.upload_file,
                            size: 48, // Adjust size as needed
                            color: Colors.blue, // Adjust color as needed
                          ),
          
                          // Added a tiny bit of space between icon and text
                          const SizedBox(height: 8),
          
                          // 2. Styled text decorations
                          const Text(
                            'Tap to select file',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
          
                          const SizedBox(
                            height: 4,
                          ), // Space between the two texts
          
                          const Text(
                            'Secure local processing',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                              decoration: TextDecoration
                                  .underline, // Example of a literal decoration (underline)
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
      ),
    );
  }
}
