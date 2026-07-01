import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity/data/format_registry.dart';
import 'package:velocity/services/recent_file_service.dart';
import 'package:velocity/models/fileOperationModel.dart';
import 'package:velocity/models/recentFileModel.dart';
import 'package:velocity/services/media_store_service.dart';

class ConversionCompletedPage extends StatelessWidget {
  final List<FileOperationItem> operations;

  const ConversionCompletedPage({super.key, required this.operations});
  // --- MASS DOWNLOAD LOGIC ---
  Future<void> _downloadAllFiles(BuildContext context) async {
    try {
      int savedMediaCount = 0;
      final recentsService = RecentFilesService();

      for (final item in operations) {
        final srcExt = item.originalExtension;
        final targetExt = item.selectedTargetExtension;
        final filePath = item.file.path;

        if (filePath == null || targetExt == null) continue;

        final file = File(filePath);

        if (!await file.exists()) continue;

        // Save into the appropriate public location
        final result = await MediaStoreService.save(
          filePath: filePath,
          mediaType: FormatRegistry.getMediaType(targetExt),
        );


        final savedPath = result['uri'];
        final savedName = result['name'];
        debugPrint("Saved path: $savedPath");
        savedMediaCount++;

        await recentsService.addRecentFile(
          RecentFile(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            fileName: savedName,
            path: savedPath,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            size: await file.length(),
            sourceExtension: srcExt,
            targetExtension: targetExt,
          ),
        );
      }

      if (context.mounted && savedMediaCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully saved $savedMediaCount files!"),
            backgroundColor: const Color(0xFF64FFDA),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving files: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- SYSTEM SHARE SHEET LOGIC ---
  void _shareAllFiles() {
    final filesToShare = operations
        .where((op) => op.file.path != null)
        .map((op) => XFile(op.file.path!))
        .toList();

    if (filesToShare.isNotEmpty) {
      // Invoke sharing using the new Instance + ShareParams approach
      SharePlus.instance.share(
        ShareParams(
          files: filesToShare,
          text: 'Check out my converted files from Velocity!',
        ),
      );
    }
  }

  // Future<void> saveConvertedFile({
  //   required String path,
  //   required String extension,
  // }) async {
  //   final category = FormatRegistry.extensionToCategory[extension];

  //   switch (category) {
  //     case "Image":
  //       await MediaStore().saveFile(
  //         tempFilePath: path,
  //         dirType: DirType.photo,
  //         dirName: DirName.pictures,
  //         relativePath: "Velocity",
  //       );
  //       break;

  //     case "Video":
  //       await MediaStore().saveFile(
  //         tempFilePath: path,
  //         dirType: DirType.video,
  //         dirName: DirName.movies,
  //         relativePath: "Velocity",
  //       );
  //       break;

  //     case "Audio":
  //       await MediaStore().saveFile(
  //         tempFilePath: path,
  //         dirType: DirType.audio,
  //         dirName: DirName.music,
  //         relativePath: "Velocity",
  //       );
  //       break;

  //     case "Document":
  //       await MediaStore().saveFile(
  //         tempFilePath: path,
  //         dirType: DirType.download,
  //         dirName: DirName.download,
  //         relativePath: "Velocity",
  //       );
  //       break;

  //     default:
  //       await MediaStore().saveFile(
  //         tempFilePath: path,
  //         dirType: DirType.download,
  //         dirName: DirName.download,
  //         relativePath: "Velocity",
  //       );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Filter out only the successfully converted files
    // final completedOps = operations
    //     .where((op) => op.status == ConversionStatus.done)
    //     .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121315), // Deep dark theme background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP CLOSE BUTTON ---
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ),
              const Spacer(),

              // --- CONCENTRIC HERO SUCCESS BADGE ---
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer decorative ring
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF64FFDA).withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    // Inner filled check circle
                    Container(
                      height: 90,
                      width: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFF64FFDA), // Accent teal
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF121315), // Dark matching contrast
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- HEADINGS ---
              Center(
                child: Text(
                  "Conversion Complete",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "${operations.length} files processed",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const Spacer(),

              // --- DUAL MAIN ACTION ACTION BUTTONS ---
              ElevatedButton.icon(
                onPressed: () => _downloadAllFiles(context),
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: Color(0xFF121315),
                ),
                label: const Text(
                  "Download All",
                  style: TextStyle(
                    color: Color(0xFF121315),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64FFDA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _shareAllFiles,
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  "Share",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white30, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const Spacer(),

              // --- PROCESSED FILES CONSTRAINED QUEUE BOX ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2024),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Inner Queue Header Label Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white10),
                        ),
                      ),
                      child: const Text(
                        "PROCESSED FILES",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Core List Scroll Area
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.28,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: operations.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: Colors.white10, height: 1),
                        itemBuilder: (context, index) {
                          final item = operations[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.movie_creation_outlined,
                                    color: Colors.grey[400],
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        "${item.originalExtension.toUpperCase()} → ${item.selectedTargetExtension?.toUpperCase()} · ${(item.file.size / 1024 / 1024).toStringAsFixed(1)} MB",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Text Action trigger anchor
                                TextButton(
                                  onPressed: () async {
                                    if (item.file.path != null) {
                                      // Open the file from its temporary cache path directly
                                      final result = await OpenFilex.open(
                                        item.file.path!,
                                      );

                                      if (result.type != ResultType.done) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Could not open file: ${result.message}",
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "File path is missing!",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "Open",
                                    style: TextStyle(
                                      color: Color(0xFF64FFDA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // --- BOTTOM BACK LINK ---
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text(
                    "Return to Dashboard",
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
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
