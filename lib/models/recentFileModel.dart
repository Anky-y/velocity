import 'package:velocity/data/format_registry.dart';

class RecentFile {
  final String id;
  final String path;
  final String fileName;
  final int timestamp; // Epoch milliseconds
  final int size; // Bytes
  final String sourceExtension;
  final String targetExtension;

  RecentFile({
    required this.id,
    required this.path,
    required this.fileName,
    required this.timestamp,
    required this.size,
    required this.sourceExtension,
    required this.targetExtension,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'fileName': fileName,
    'timestamp': timestamp,
    'size': size,
    'sourceExtension': sourceExtension,
    'targetExtension': targetExtension,
  };

  String get mediaType => FormatRegistry.getMediaType(targetExtension);

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
    id: json['id'],
    path: json['path'],
    fileName: json['fileName'],
    timestamp: json['timestamp'],
    size: json['size'],
    targetExtension: json['targetExtension'],
    sourceExtension: json['sourceExtension'],
  );
}
