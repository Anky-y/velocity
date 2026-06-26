import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:velocity/core/helper/sharedWidgets.dart';
import 'package:velocity/core/helper/util.dart';
import 'package:velocity/data/format_registry.dart';
import 'package:velocity/models/fileOperationModel.dart';

class FileDetailsPage extends StatefulWidget {
  final List<FileOperationItem> operations;

  const FileDetailsPage({super.key, required this.operations});

  @override
  State<FileDetailsPage> createState() => _FileDetailsPageState();
}

class _FileDetailsPageState extends State<FileDetailsPage> {
  String? universalSelectedFormat;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Velocity".toUpperCase()),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- UNIVERSAL FORMAT DROPDOWN CARD ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "UNIVERSAL FORMAT",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Apply to ${widget.operations.length} files",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),

                    FormatSelectorButton(
                      batchExtensions: widget.operations
                          .map((op) => op.originalExtension)
                          .toList(),

                      // 1. Tell the button to display this variable!
                      initialValue: universalSelectedFormat,

                      onFormatSelected: (universalOutputFormat) {
                        print(
                          "Batch setting matching files to: $universalOutputFormat",
                        );

                        setState(() {
                          // 2. Update the visual text for the universal button itself
                          universalSelectedFormat = universalOutputFormat;

                          // 3. Update all the individual list items (your existing logic)
                          for (var operation in widget.operations) {
                            final validTargets = FormatRegistry.getTargets(
                              operation.originalExtension,
                            );

                            if (validTargets.contains(
                              universalOutputFormat.toLowerCase(),
                            )) {
                              operation.selectedTargetExtension =
                                  universalOutputFormat;
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- QUEUE HEADER ---
              Text(
                "Queue (${widget.operations.length})",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),

              // --- QUEUE LIST ---
              // Expanded(child: Text("data")),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.operations.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 10);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final operation = widget.operations[index];
                    return Container(
                      height: 50,
                      child: Row(
                        children: [
                          Container(height: 30, width: 30),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  operation.file.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${operation.file.size.toReadableSize} · ${operation.originalExtension.toUpperCase()}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          //Container(height: 30, width: 30),
                          FormatSelectorButton(
                            singleExtension: operation.originalExtension,

                            // 1. THIS IS THE CRITICAL LINE! It tells the button what text to display based on your state.
                            initialValue: operation.selectedTargetExtension,

                            onFormatSelected: (outputFormat) {
                              // 2. THIS IS THE TRIGGER. It forces the screen to redraw with the new initialValue.
                              setState(() {
                                operation.selectedTargetExtension =
                                    outputFormat;
                              });

                              print(
                                "Convert individual file to: $outputFormat",
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- CONVERT BUTTON ---
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sync, color: Colors.black),
                label: const Text(
                  "CONVERT 2 OF 3 FILES",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//   // Helper widget builder for standard queue rows
//   Widget _buildQueueItem({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required String formatText,
//     required Color cardColor,
//   }) {
//     return Container(
//       color: cardColor,
//       padding: const EdgeInsets.all(12.0),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF161618),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: iconColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Theme.of(
//                 context,
//               ).colorScheme.outline, // Subdued dotted border color

//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: Colors.grey[800]!),
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   formatText,
//                   style: const TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(
//                   Icons.keyboard_arrow_down,
//                   color: Colors.grey,
//                   size: 16,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Icon(Icons.close, color: Colors.grey, size: 20),
//         ],
//       ),
//     );
//   }
// }
