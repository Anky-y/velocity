import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:velocity/data/format_registry.dart';

class OperationType {
  final String name;
  final String description;
  final IconData icon;

  const OperationType({
    required this.name,
    required this.description,
    required this.icon,
  });
}

enum ConversionStatus { pending, processing, done, failed }

class FileOperationItem {
  final String id;
  PlatformFile file; // The actual file picked
  final String originalExtension; // e.g., 'png'
  String?
  selectedTargetExtension; // e.g., 'pdf' (null if user hasn't picked yet)

  ConversionStatus status;
  double progress;

  FileOperationItem({
    required this.id,
    required this.file,
    required this.originalExtension,
    this.selectedTargetExtension,
    this.status = ConversionStatus.pending,
    this.progress = 0.0,
  });

  // Dynamically lookup what this specific file can be converted into
  List<String> get availableTargetExtensions {
    return FormatRegistry.conversionRules[originalExtension] ?? [];
  }

  // Helper to check if this item is ready for processing
  bool get isReady => selectedTargetExtension != null;

  // Helper to check if a universal format is supported by this file
  bool supportsFormat(String format) {
    return availableTargetExtensions.contains(format);
  }

  FileOperationItem copyWith({
    String? id,
    PlatformFile? file,
    String? originalExtension,
    String? selectedTargetExtension,
    ConversionStatus? status,
    double? progress,
  }) {
    return FileOperationItem(
      id: id ?? this.id,
      file: file ?? this.file,
      originalExtension: originalExtension ?? this.originalExtension,
      selectedTargetExtension:
          selectedTargetExtension ?? this.selectedTargetExtension,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}
