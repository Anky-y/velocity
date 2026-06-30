class RecentFile {
  final String id;
  final String path;
  final String fileName;
  final int timestamp; // Epoch milliseconds
  final int size; // Bytes
  final String fileMediaType;

  RecentFile({
    required this.id,
    required this.path,
    required this.fileName,
    required this.timestamp,
    required this.size,
    required this.fileMediaType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'fileName': fileName,
    'timestamp': timestamp,
    'size': size,
    'fileMediaType': fileMediaType,
  };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
    id: json['id'],
    path: json['path'],
    fileName: json['fileName'],
    timestamp: json['timestamp'],
    size: json['size'],
    fileMediaType: json['fileMediaType'],
  );
}
