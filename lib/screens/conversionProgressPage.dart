import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:velocity/models/fileOperationModel.dart';
import 'package:velocity/screens/conversion_completed_page.dart';
import 'package:velocity/services/conversion/conversion_manager.dart';
import 'package:path/path.dart' as p;

class ConversionProgressPage extends StatefulWidget {
  final List<FileOperationItem> operations;

  const ConversionProgressPage({super.key, required this.operations});

  @override
  State<ConversionProgressPage> createState() => _ConversionProgressPageState();
}

class _ConversionProgressPageState extends State<ConversionProgressPage> {
  @override
  void initState() {
    super.initState();
    // Start the conversion loop immediately as soon as the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _runConversionPipeline();
  });
  }

  Future<void> _runConversionPipeline() async {
    for (var operation in widget.operations) {
      if (operation.selectedTargetExtension == null ||
          operation.file.path == null) {
        continue;
      }

      debugPrint("DEBUG: ${operation.status}");

      // 1. Mark item active and rebuild screen
      setState(() {
        operation.status = ConversionStatus.processing;
        operation.progress = 0.0;
      });
      debugPrint("DEBUG 2: ${operation.status}");

      try {
        final String fileType = operation.fileMediaType;
        // 2. Call your existing conversion engine
        File convertedFile = await ConversionManager.execute(
          filePath: operation.file.path!,
          fromExtension: operation.originalExtension,
          targetExtension: operation.selectedTargetExtension!, fileType: fileType,
          onProgress: (progressValue) {
            // Every time the image package processes a step, this runs!
            setState(() {
              operation.progress = progressValue;
              debugPrint("DEBUG 3: ${operation.status}");
            });
          },
        );

        debugPrint("DEBUG 4: ${operation.status}");

        // 3. Mark current item as finished
        setState(() {
          // Update your model path to point to the newly converted physical disk file!
          operation.file = PlatformFile(
            path: convertedFile.path,
            name: p.basename(convertedFile.path),
            size: convertedFile.lengthSync(), // Real updated file size
            bytes: null,
          );

          operation.status = ConversionStatus.done;
          operation.progress = 1.0;
          debugPrint("DEBUG 5: ${operation.status}");
        });
      } catch (error) {
        setState(() {
          operation.status = ConversionStatus.failed;
          debugPrint("DEBUG 5: ${operation.status} ${error}");
        });
      }
    }

    if (mounted) {
      // Wait a split second so the user actually notices the final item hit 100%
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Filter the explicitly successful items right here!
        final completelyFinishedOps = widget.operations
            .where((op) => op.status == ConversionStatus.done)
            .toList();

        print(
          "Passing ${completelyFinishedOps.length} successfully converted files to completed page.",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ConversionCompletedPage(operations: completelyFinishedOps),
          ),
        );
      }
    }
    print("All conversions finished!");
  }

  @override
  Widget build(BuildContext context) {
    // UI Calculations for the radial tracker
    final activeOps = widget.operations
        .where((op) => op.selectedTargetExtension != null)
        .toList();
    int totalFiles = activeOps.length;
    int completedFiles = activeOps
        .where((op) => op.status == ConversionStatus.done)
        .length;

    double totalProgressSum = activeOps.fold(
      0.0,
      (sum, item) => sum + item.progress,
    );
    double overallProgress = totalFiles > 0
        ? (totalProgressSum / totalFiles)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121315), // Deep dark theme background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP HEADER ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Converting",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      // Reset files back to pending if they exit out early
                      for (var op in widget.operations) {
                        op.status = ConversionStatus.pending;
                        op.progress = 0.0;
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- LARGE RADIAL TRACKER RING ---
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: CircularProgressIndicator(
                        value: overallProgress,
                        strokeWidth: 8,
                        color: const Color(
                          0xFF64FFDA,
                        ), // Bright layout accent cyan
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(overallProgress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$completedFiles of $totalFiles items",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- ESTIMATED TIME METRIC ---
              const Center(
                child: Column(
                  children: [
                    Text(
                      "ESTIMATED TIME REMAINING",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "00:02:45",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- PROCESSING QUEUE LABEL ---
              const Text(
                "PROCESSING QUEUE",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // --- SCROLLING RUNTIME ITEMS QUEUE ---
              Expanded(
                child: ListView.separated(
                  itemCount: widget.operations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.operations[index];
                    final isProcessing =
                        item.status == ConversionStatus.processing;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2024),
                        borderRadius: BorderRadius.circular(10),
                        border: isProcessing
                            ? Border.all(
                                color: const Color(0xFF64FFDA).withOpacity(0.4),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.movie_creation_outlined,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.file.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.status == ConversionStatus.done
                                          ? "Done"
                                          : "to .${item.selectedTargetExtension ?? '???'}",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (item.status == ConversionStatus.done)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF64FFDA),
                                  size: 22,
                                )
                              else if (isProcessing)
                                Text(
                                  "${(item.progress * 100).toInt()}%",
                                  style: const TextStyle(
                                    color: Color(0xFF64FFDA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey[700],
                                  size: 22,
                                ),
                            ],
                          ),

                          if (isProcessing) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: item.progress,
                                minHeight: 4,
                                color: const Color(0xFF64FFDA),
                                backgroundColor: Colors.white10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // --- LOWER CANCEL OPERATION BAR ---
              OutlinedButton(
                onPressed: () {
                  for (var op in widget.operations) {
                    op.status = ConversionStatus.pending;
                    op.progress = 0.0;
                  }
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[800]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Cancel Operation",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
