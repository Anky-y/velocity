import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'base_converter.dart';

/// Handles PNG to JPG specifically
class PngToJpgConverter implements FileConverter {
  @override
  Future<File> convert(
    File inputFile,
    String targetExtension, {
    void Function(double progress)? onProgress,
  }) async {
    // Simulate progression steps for your progress bars
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (onProgress != null) onProgress(i / 10.0);
    }

    final tempDir = await getTemporaryDirectory();
    final outputPath = p.join(
      tempDir.path,
      "${p.basenameWithoutExtension(inputFile.path)}.$targetExtension",
    );
    return await File(outputPath).writeAsString("Done");
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
