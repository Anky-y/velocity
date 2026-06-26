import 'dart:io';

abstract class FileConverter {
  /// Added an optional [onProgress] callback that passes back a value from 0.0 to 1.0
  Future<File> convert(
    File inputFile,
    String targetExtension, {
    void Function(double progress)? onProgress,
  });
}
