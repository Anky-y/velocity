import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:velocity/data/format_registry.dart';
import 'package:velocity/services/conversion/document_converters.dart';
import 'image_converters.dart';
import 'videoAudio_converters.dart'; // 🚀 Added import for the new video converter worker
import 'dart:async';

class ConversionManager {
  static Future<File> execute({
    required String filePath,
    required String fromExtension,
    required String targetExtension,
    required String? fileType, // 'image', 'video', or 'audio'
    required void Function(double) onProgress,
  }) async {
    final cleanFrom = fromExtension.toLowerCase().trim();
    final cleanTarget = targetExtension.toLowerCase().trim();

    // 1. Fetch categorical mappings directly from your updated registry
    final sourceCategory =
        FormatRegistry.extensionToCategory[cleanFrom] ?? 'Image';
    final targetCategory =
        FormatRegistry.extensionToCategory[cleanTarget] ?? 'Image';

    // 2. Set up system temporary destination cache path
    final tempDir = Directory.systemTemp;
    final String outputFileName =
        'temp_conv_${DateTime.now().millisecondsSinceEpoch}.$cleanTarget';
    final String outputPath = p.join(tempDir.path, outputFileName);

    if (sourceCategory == 'Document' || targetCategory == 'Document') {
      return await DocumentConverters.convertDocumentFormat(
        filePath: filePath,
        outputPath: outputPath,
        targetExtension: cleanTarget,
      );
    }
    // 3. ELEGANT TRAFFIC ROUTING:
    else if (sourceCategory == 'Image' &&
        targetCategory == 'Image' &&
        cleanFrom != 'gif' &&
        cleanTarget != 'gif' &&
        cleanFrom != 'tiff' &&
        cleanTarget != 'tiff') {
      // 🖼️ Pass to your legacy image conversion processor module
      return executeImageConversion(
        filePath: filePath,
        fromExtension: fromExtension,
        targetExtension: cleanTarget,
        onProgress: onProgress,
      );
    } else {
      // 🚀 FFmpeg handles everything else (Video➔Video, Video➔Audio, Video➔GIF, Audio➔Audio)
      return VideoAudioConverters.convertVideoAudioFormat(
        inputPath: filePath,
        outputPath: outputPath,
        targetExtension: cleanTarget,
        onProgress: onProgress,
      );
    }
  }

  // Map specific conversion routines using a "from_to" string key format
  static Future<File> executeImageConversion({
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
    //Placeholder function
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

  static Future<File> executeVideoConversion({
    required String filePath,
    required String targetExtension,
    void Function(double progress)? onProgress,
  }) async {
    final sourceFile = File(filePath);
    final targetExtClean = targetExtension.replaceAll('.', '').toLowerCase();

    if (!await sourceFile.exists()) {
      throw Exception("Source file not found at: $filePath");
    }

    onProgress?.call(0.1); // Setup started

    // 1. Generate the output path in the temporary directory
    final tempDir = await getTemporaryDirectory();
    final originalName = p.basenameWithoutExtension(filePath);

    // --- NEW RENAMING LOGIC START ---
    String newPath = p.join(
      tempDir.path,
      "${originalName}_converted.$targetExtClean",
    );

    int counter = 1;
    // Loop continues until it finds a filename that does NOT exist
    while (await File(newPath).exists()) {
      newPath = p.join(
        tempDir.path,
        "${originalName}_converted_$counter.$targetExtClean",
      );
      counter++;
    }
    return VideoAudioConverters.convertVideoAudioFormat(
      inputPath: filePath,
      outputPath: newPath,
      targetExtension: targetExtension,
      onProgress: onProgress,
    );
  }
}
