import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'image_converters.dart';

import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';

class ConversionManager {
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

  static Future<File> execute({
    required String filePath,
    required String fromExtension,
    required String targetExtension,
    String fileType = "document",
    void Function(double progress)? onProgress,
    // <-- 1. ADD THIS LINE
  }) {
    switch (fileType) {
      case "image":
        return executeImageConversion(
          filePath: filePath,
          fromExtension: fromExtension,
          targetExtension: targetExtension,
          onProgress: onProgress
        );
      case "audio":
        throw UnimplementedError("Audio conversion not yet implemented");

      case "video":
        return executeVideoConversion(
          filePath: filePath,
          targetExtension: targetExtension,
          onProgress: onProgress

        );
        throw UnimplementedError("Video conversion not yet implemented");
      default:
        throw UnsupportedError("Unsupported file type: $fileType");
    }
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
    // --- NEW RENAMING LOGIC END ---

    // 2. Build the FFmpeg command
    String command = '-i "$filePath" "$newPath"';

    onProgress?.call(0.2); // FFmpeg starting

    // 3. Execute the conversion
    final completer = Completer<File>();

    await FFmpegKit.executeAsync(
      command,
      (Session session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          onProgress?.call(1.0); // 100% Done
          completer.complete(File(newPath)); 
        } else {
          final failStackTrace = await session.getFailStackTrace();
          completer.completeError(
            Exception(
              "Video Conversion Failed. Code: $returnCode\n$failStackTrace",
            ),
          );
        }
      },
      (log) {
        // print(log.getMessage());
      },
      (statistics) {
        onProgress?.call(0.5);
      },
    );

    return completer.future;
  }
}
