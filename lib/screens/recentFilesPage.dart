import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity/core/theme/app_colors.dart';
import 'package:velocity/data/recent_file_service.dart';
import 'package:velocity/models/recentFileModel.dart';
import 'package:velocity/screens/homePage.dart';
import 'package:open_filex/open_filex.dart';

class RecentFilesPage extends StatefulWidget {
  const RecentFilesPage({Key? key}) : super(key: key);

  @override
  State<RecentFilesPage> createState() => _RecentFilesPageState();
}

class _RecentFilesPageState extends State<RecentFilesPage> {
  String _selectedFilter = "All Formats";

  final List<String> _filters = [
    "All Formats",
    "Image",
    "Video",
    "Audio",
    "Documents",
  ];

  Map<String, List<RecentFile>> _groupFilesByDate(List<RecentFile> files) {
    final Map<String, List<RecentFile>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var file in files) {
      final fileDate = DateTime.fromMillisecondsSinceEpoch(file.timestamp);
      final compareDate = DateTime(fileDate.year, fileDate.month, fileDate.day);

      String category;
      if (compareDate == today) {
        category = "Today";
      } else if (compareDate == yesterday) {
        category = "Yesterday";
      } else {
        category = DateFormat('MMMM d, yyyy').format(fileDate);
      }

      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(file);
    }
    return grouped;
  }

  bool _matchesFilter(RecentFile file) {
    if (_selectedFilter == "All Formats") return true;

    final mediaType = file.fileMediaType.toLowerCase();
    final ext = file.fileName.split('.').last.toLowerCase();

    switch (_selectedFilter) {
      case "Image":
        return mediaType == 'image' ||
            ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
      case "Video":
        return mediaType == 'video' ||
            ['mp4', 'mkv', 'mov', 'avi'].contains(ext);
      case "Audio":
        return mediaType == 'audio' ||
            ['mp3', 'wav', 'm4a', 'flac'].contains(ext);
      case "Documents":
        return mediaType == 'document' ||
            ['pdf', 'docx', 'doc', 'txt', 'xlsx', 'pptx'].contains(ext);
      default:
        return true;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }
    return "${(bytes / 1024).toStringAsFixed(1)} KB";
  }

  IconData _getFileIcon(String mediaType, String ext) {
    final mediaLower = mediaType.toLowerCase();
    final extLower = ext.toLowerCase();

    if (mediaLower == 'image') return Icons.image_outlined;
    if (mediaLower == 'video') return Icons.movie_creation_outlined;
    if (mediaLower == 'audio' || extLower == 'mp3')
      return Icons.audiotrack_outlined;
    if (extLower == 'pdf') return Icons.picture_as_pdf_outlined;
    return Icons.description_outlined;
  }

  // --- ACTIONS ENGINE ---

  // 1. Clear All History with Confirmation Dialog
  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Clear History?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "This will clear your conversion list logs. The actual downloaded files remain safe on your device storage.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[500])),
            ),
            TextButton(
              onPressed: () async {
                // Call clear service routine
                await RecentFilesService().clearRegistry();
                Navigator.pop(context);
                setState(() {}); // Refresh empty viewport state
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Conversion history cleared")),
                );
              },
              child: const Text(
                "Clear All",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 2. Handle 3-Dot Dropdown Selections Dynamically
  void _handleMenuAction(String action, RecentFile fileItem) async {
    final file = File(fileItem.path);

    if (action != 'delete_file' && !await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File no longer exists at this path location."),
        ),
      );
      return;
    }

    switch (action) {
      case 'view_file':
        // Native platform opening handler intent
        await OpenFilex.open(fileItem.path);
        break;

      case 'share_file':
        // Uses native system dialogue presentation manager sheets
        await Share.shareXFiles([
          XFile(fileItem.path),
        ], text: 'Check out my converted file!');
        break;

      case 'delete_file':
        // Dual-action safety delete: eliminates registry entry AND local system track
        try {
          if (await file.exists()) {
            await file.delete();
          }
          // Remove the single item signature trace dynamically via cache service
          await RecentFilesService().removeSingleRecord(fileItem.path);
          setState(() {}); // Refresh stream state pipeline
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File permanently removed.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting system asset asset: $e")),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? DarkColors.mutedText : LightColors.mutedText;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text("Velocity".toUpperCase()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Clear History",
            onPressed: _clearAllHistory, // Wired Up
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<RecentFile>>(
          future: RecentFilesService().getValidRecents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawRecents = snapshot.data ?? [];
            final filteredRecents = rawRecents.where(_matchesFilter).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Conversions",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your file conversion history for the last 30 days.",
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _filters.map((filter) {
                        return _buildFilterChip(
                          filter,
                          isActive: _selectedFilter == filter,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: filteredRecents.isEmpty
                        ? Center(
                            child: Text(
                              "No matching results found.",
                              style: TextStyle(
                                color: textMuted,
                                fontFamily: "InterVariable",
                              ),
                            ),
                          )
                        : _buildGroupedListView(
                            filteredRecents,
                            _groupFilesByDate(filteredRecents),
                            textMuted,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 1),
    );
  }

  Widget _buildGroupedListView(
    List<RecentFile> rawList,
    Map<String, List<RecentFile>> groupedData,
    Color textMuted,
  ) {
    final categories = groupedData.keys.toList();

    return ListView.builder(
      itemCount: categories.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, catIdx) {
        final categoryTitle = categories[catIdx];
        final items = groupedData[categoryTitle]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryTitle,
                  style: TextStyle(
                    color: textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${items.length} ${items.length == 1 ? 'item' : 'items'}",
                  style: TextStyle(
                    color: textMuted.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, itemIdx) {
                final item = items[itemIdx];
                final targetExt = item.fileName.split('.').last.toUpperCase();
                final timeString = DateFormat(
                  'hh:mm a',
                ).format(DateTime.fromMillisecondsSinceEpoch(item.timestamp));

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getFileIcon(item.fileMediaType, targetExt),
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'JetBrainsMonoVariable',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildExtensionBadge(
                                  item.fileMediaType == 'image'
                                      ? 'PNG'
                                      : 'DOCX',
                                ),
                                paddingBoxHorizontal(4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: textMuted,
                                  size: 12,
                                ),
                                paddingBoxHorizontal(4),
                                _buildExtensionBadge(targetExt, isTarget: true),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: textMuted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatFileSize(item.size),
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'InterVariable',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeString,
                            style: TextStyle(
                              color: textMuted.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),

                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: textMuted),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            elevation: 3,
                            onSelected: (String action) =>
                                _handleMenuAction(action, item), // Wired Up
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'view_file',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'View File',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'share_file',
                                    child: Row(
                                      children: [
                                        Icon(Icons.share_outlined, size: 18),
                                        SizedBox(width: 10),
                                        Text(
                                          'Share File',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<String>(
                                    value: 'delete_file',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Delete File',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String text, {required bool isActive}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[500],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            fontFamily: "InterVariable",
          ),
        ),
      ),
    );
  }

  Widget _buildExtensionBadge(String ext, {bool isTarget = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isTarget
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        ext,
        style: TextStyle(
          color: isTarget
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[400],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget paddingBoxHorizontal(double width) => SizedBox(width: width);
}
