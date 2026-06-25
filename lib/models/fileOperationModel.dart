import 'package:file_picker/file_picker.dart';
import 'package:velocity/data/formatRegistry.dart';

enum OperationType { convert, compress, merge }

class FileOperationItem {
  final String id;
  final PlatformFile file;             // The actual file picked
  final String originalExtension;      // e.g., 'png'
  String? selectedTargetExtension;     // e.g., 'pdf' (null if user hasn't picked yet)

  FileOperationItem({
    required this.id,
    required this.file,
    required this.originalExtension,
    this.selectedTargetExtension,
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
}