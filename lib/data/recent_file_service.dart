import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:velocity/models/recentFileModel.dart';

class RecentFilesService {
  static final RecentFilesService _instance = RecentFilesService._internal();
  factory RecentFilesService() => _instance;
  RecentFilesService._internal();

  List<RecentFile> _cachedList = [];

  Future<File> _getRegistryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/recents_registry.json');
  }

  // Load from local storage
  Future<void> loadRegistry() async {
    try {
      final file = await _getRegistryFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _cachedList = jsonList.map((e) => RecentFile.fromJson(e)).toList();
        // Sort by newest first
        _cachedList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      print("Error loading recents registry: $e");
    }
  }

  // Get only verified existing files
  Future<List<RecentFile>> getValidRecents() async {
    List<RecentFile> validFiles = [];
    bool registryChanged = false;

    for (var fileMeta in _cachedList) {
      if (await File(fileMeta.path).exists()) {
        validFiles.add(fileMeta);
      } else {
        // File was deleted outside the app, mark registry for a clean up
        registryChanged = true;
      }
    }

    if (registryChanged) {
      _cachedList = validFiles;
      await _saveRegistry();
    }

    return validFiles;
  }

  // Add a record when downloaded
  Future<void> addRecentFile(RecentFile file) async {
    // Prevent duplicate paths
    _cachedList.removeWhere((item) => item.path == file.path);
    _cachedList.insert(0, file);

    // Optional: Caps the history size to 50 items so the file doesn't grow infinitely
    if (_cachedList.length > 50) {
      _cachedList = _cachedList.sublist(0, 50);
    }

    await _saveRegistry();
  }

  Future<void> _saveRegistry() async {
    try {
      final file = await _getRegistryFile();
      final jsonString = jsonEncode(
        _cachedList.map((e) => e.toJson()).toList(),
      );
      await file.writeAsString(jsonString);
    } catch (e) {
      print("Error saving recents registry: $e");
    }
  }
}
