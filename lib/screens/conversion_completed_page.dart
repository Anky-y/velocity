import 'package:flutter/material.dart';
import 'package:velocity/models/fileOperationModel.dart';

class ConversionCompletedPage extends StatelessWidget {
  final List<FileOperationItem> operations;

  const ConversionCompletedPage({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    // Filter out only the successfully converted files
    final completedOps = operations
        .where((op) => op.status == ConversionStatus.done)
        .toList();

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
                          color: const Color(0xFF64FFDA).withOpacity(0.2),
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
                  "${completedOps.length} files converted successfully.",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const Spacer(),

              // --- DUAL MAIN ACTION ACTION BUTTONS ---
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Wire up local mass file storage downloading logic
                },
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
                onPressed: () {
                  // TODO: Hook up system sharing sheet sheets
                },
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
                        itemCount: completedOps.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Colors.white10, height: 1),
                        itemBuilder: (context, index) {
                          final item = completedOps[index];

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
                                    color: Colors.white.withOpacity(0.05),
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
                                  onPressed: () {
                                    // TODO: Wire up opening individual single files directly
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
