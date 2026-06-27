import 'dart:io';
import 'base_converter.dart';
import 'image_converters.dart';

class ConversionManager {
  // Map specific conversion routines using a "from_to" string key format
  static final Map<String, FileConverter> _registry = {
    'png_to_jpg': PngToJpgConverter(),
    'jpg_to_png': JpgToPngConverter(),
    'jpeg_to_png': JpgToPngConverter(),
    // You can easily add audio or video files later:
    // 'mp4_to_mp3': Mp4ToMp3Converter(),
  };

  static Future<File> execute({
    required String filePath,
    required String fromExtension,
    required String targetExtension,
    void Function(double progress)? onProgress, // <-- 1. ADD THIS LINE
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("Source file not found at: $filePath");
    }

    // Generate a lookup key like "png_to_jpg"
    final lookupKey =
        '${fromExtension.toLowerCase()}_to_${targetExtension.toLowerCase()}';

    final converter = _registry[lookupKey];
    if (converter == null) {
      throw UnimplementedError(
        "No specialized converter registered for: $lookupKey",
      );
    }

    // Hand off the operation to the exact class responsible for it
    return await converter.convert(file, targetExtension, onProgress: onProgress,
    );
  }
}
