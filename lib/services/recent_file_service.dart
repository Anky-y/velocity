import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velocity/models/recentFileModel.dart';
import 'package:velocity/services/media_store_service.dart';



class RecentFilesService {
  static final RecentFilesService _instance = RecentFilesService._internal();
  factory RecentFilesService() => _instance;
  RecentFilesService._internal();

  List<RecentFile> _cachedList = [];

  bool _loaded = false;

  Future<File> _getRegistryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/recents_registry.json');
  }

  // Load from local storage
  Future<void> loadRegistry() async {
    if (_loaded) return;

    try {
      final file = await _getRegistryFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _cachedList = jsonList.map((e) => RecentFile.fromJson(e)).toList();
        // Sort by newest first
        _cachedList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      _loaded = true;
    } catch (e) {
      debugPrint("Error loading recents registry: $e");
      _loaded = true;
    }
  }

  // Get only verified existing files
  Future<List<RecentFile>> getValidRecents() async {
    await loadRegistry();

    List<RecentFile> validFiles = [];
    bool registryChanged = false;

    for (var fileMeta in _cachedList) {
      bool exists;

      if (fileMeta.path.startsWith("content://")) {
        exists = await MediaStoreService.fileExists(fileMeta.path);
      } else {
        exists = await File(fileMeta.path).exists();
      }

      if (exists) {
        validFiles.add(fileMeta);
      } else {
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
    await loadRegistry();

    // Prevent duplicate paths
    _cachedList.removeWhere((item) => item.path == file.path);
    _cachedList.insert(0, file);

    // Optional: Caps the history size to 50 items so the file doesn't grow infinitely
    if (_cachedList.length > 50) {
      _cachedList = _cachedList.sublist(0, 50);
    }

    await _saveRegistry();
  }

  // --- NEW WORKER HOOKS FOR THE RECENT FILES UI ---

  // Removes a single log entry trace when a file is manually targeted for disposal
  Future<void> removeSingleRecord(String path) async {
    await loadRegistry();
    _cachedList.removeWhere((item) => item.path == path);
    await _saveRegistry();
  }

  // Wipes all text database records clean when the sweeping action is invoked
  Future<void> clearRegistry() async {
    await loadRegistry();

    _cachedList.clear();
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
      debugPrint("Error saving recents registry: $e");
    }
  }
}
