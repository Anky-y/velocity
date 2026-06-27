import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'image_converters.dart';

class ConversionManager {
  // Map specific conversion routines using a "from_to" string key format
  static Future<File> execute({
    required String filePath,
    required String fromExtension,
    required String targetExtension,
    void Function(double progress)? onProgress, // <-- 1. ADD THIS LINE
  }) async {
    final sourceFile = File(filePath);
    final targetExtClean = targetExtension.toLowerCase();
    if (!await sourceFile.exists()) {
      throw Exception("Source file not found at: $filePath");
    }

    // 1. Read the input file bytes
    onProgress?.call(0.1);
    final List<int> fileBytes = await sourceFile.readAsBytes();
    onProgress?.call(0.3);

    final Uint8List uint8Bytes = Uint8List.fromList(fileBytes);

    // 2. Decode the raw bytes into an in-memory Image object
    final img.Image? decodedImage = img.decodeImage(uint8Bytes);
    if (decodedImage == null) {
      throw Exception("Could not decode image format: $fromExtension");
    }
    onProgress?.call(0.6);

    final encodedBytes = ImageConverters.convertImageFormat(
      decodedImage,
      targetExtClean,
    );
    onProgress?.call(0.8);

    final tempDir = await getTemporaryDirectory();
    final originalName = p.basenameWithoutExtension(filePath);
    final newPath = p.join(
      tempDir.path,
      "${originalName}_converted.$targetExtClean",
    );

    final outputFile = File(newPath);
    await outputFile.writeAsBytes(encodedBytes);

    onProgress?.call(1.0);
    return outputFile;
  }
}
