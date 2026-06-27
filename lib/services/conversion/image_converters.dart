import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'base_converter.dart';
import 'package:image/image.dart' as img;
/// Handles PNG to JPG specifically
class PngToJpgConverter implements FileConverter {
  @override
  Future<File> convert(
    File inputFile,
    String targetExtension, {
    void Function(double progress)? onProgress,
  }) async {
    // 1. Tell the UI we are beginning the read/decode phase
    if (onProgress != null) onProgress(0.1);

    // 2. Read the file bytes directly from the hard drive path
    final Uint8List fileBytes = await inputFile.readAsBytes();
    if (onProgress != null) onProgress(0.3);

    // 3. Decode the raw compressed PNG stream into a pixel buffer map
    final img.Image? decodedImage = img.decodePng(fileBytes);

    if (decodedImage == null) {
      throw Exception("Failed to decode PNG image data.");
    }
    if (onProgress != null) onProgress(0.6);

    // 4. Re-encode the raw pixel map into a compressed JPG format byte stream
    // quality: 85 provides an excellent balance of file size reduction and clear visibility
    final List<int> jpgBytes = img.encodeJpg(decodedImage, quality: 85);
    if (onProgress != null) onProgress(0.8);

    // 5. Prepare the output file path destination inside the app temporary sandbox
    final tempDir = await getTemporaryDirectory();
    final originalName = p.basenameWithoutExtension(inputFile.path);
    final outputPath = p.join(tempDir.path, "$originalName.$targetExtension");

    // 6. Save the actual byte arrays to the file system
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(jpgBytes);

    // 7. Complete the loading indicators
    if (onProgress != null) onProgress(1.0);

    return outputFile;
  }
}

/// Handles JPG to PNG specifically
class JpgToPngConverter implements FileConverter {
  @override
  Future<File> convert(
    File inputFile,
    String targetExtension, {
    void Function(double progress)? onProgress,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final tempDir = await getTemporaryDirectory();
    final originalName = p.basenameWithoutExtension(inputFile.path);
    final outputPath = p.join(tempDir.path, "$originalName.png");

    return await File(
      outputPath,
    ).writeAsString("Actual converted PNG binary stream mock data");
  }
}
