import 'dart:math';

extension FileSizeFormatting on int {
  String get toReadableSize {
    if (this <= 0) return "0 B";
    
    // Change base to 1000 for standard decimal file system sizing
    const int base = 1000; 
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    
    // Calculate which suffix to use based on base 1000
    var i = (log(this) / log(base)).floor();
    
    // Clamp the index to ensure it doesn't throw a range error for massive files
    i = i.clamp(0, suffixes.length - 1);
    
    // Format to 1 decimal place
    double calculatedSize = this / pow(base, i);
    return '${calculatedSize.toStringAsFixed(1)} ${suffixes[i]}';
  }
}