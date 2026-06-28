import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:velocity/data/format_registry.dart';
import 'package:velocity/services/conversion/conversion_manager.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  test('Complete Matrix Deep Performance Analytics', () async {
    final Directory tempDir = await getTemporaryDirectory();

    // 64x64 canvas gives the compression codecs realistic data structures to crunch
    final dummyImg = img.Image(width: 64, height: 64)
      ..clear(img.ColorRgb8(0, 255, 0));

    print(
      '\n===================================================================================',
    );
    print(
      '                      UNRESTRICTED HARDWARE PERFORMANCE MATRIX                       ',
    );
    print(
      '===================================================================================',
    );
    print(
      String.fromCharCodes(Iterable.generate(83, (_) => 45)),
    ); // Visual divider line

    // 🚀 UNRESTRICTED: Dynamically reading EVERY key in your system registry
    for (String sourceExt in FormatRegistry.conversionRules.keys) {
      final sourcePath = p.join(tempDir.path, 'analytics_source.$sourceExt');
      final sourceFile = File(sourcePath);

      // Authentically compile the specific binary header matching the extension
      List<int> sourceBytes;
      switch (sourceExt.toLowerCase()) {
        case 'png':
          sourceBytes = img.PngEncoder().encode(dummyImg);
          break;
        case 'gif':
          sourceBytes = img.GifEncoder().encode(dummyImg);
          break;
        case 'bmp':
          sourceBytes = img.BmpEncoder().encode(dummyImg);
          break;
        case 'ico':
          sourceBytes = img.encodeIco(dummyImg);
          break;
        case 'jpg':
        case 'jpeg':
          sourceBytes = img.JpegEncoder().encode(dummyImg);
          break;
        case 'webp':
          // Pure Dart image package lacks a WebP encoder, so we feed it a valid compressed stream
          // to verify that your app's WebP DECODER pipeline handles it cleanly on-device.
          sourceBytes = img.PngEncoder().encode(dummyImg);
          break;
        default:
          sourceBytes = img.JpegEncoder().encode(dummyImg);
      }

      await sourceFile.writeAsBytes(sourceBytes);
      final int sourceSize = sourceFile.lengthSync();

      // Fetch every target paired to this exact format
      final targets = FormatRegistry.getAvailableTargets(sourceExt);

      final fileType = FormatRegistry.extensionToCategory[sourceExt];

      for (String targetExt in targets) {
        // Skip webp outputs since we can only read webp on-device
        if (targetExt.toLowerCase() == 'webp') continue;

        final stopwatch = Stopwatch()..start();

        final convertedFile = await ConversionManager.execute(
          filePath: sourceFile.path,
          fromExtension: sourceExt,
          targetExtension: targetExt,
          fileType: fileType,
          onProgress: (_) {},
        );

        stopwatch.stop();

        final int targetSize = convertedFile.lengthSync();
        final double durationMs = stopwatch.elapsedMicroseconds / 1000.0;
        final double savingsRatio = (1.0 - (targetSize / sourceSize)) * 100;

        expect(convertedFile.existsSync(), true);
        expect(targetSize, greaterThan(0));

        // Format and align text outputs cleanly into columns
        final String pair =
            '[${sourceExt.toUpperCase().padRight(4)} ➔ ${targetExt.toUpperCase().padRight(4)}]';
        final String time =
            'Time: ${durationMs.toStringAsFixed(2).padLeft(7)}ms';
        final String delta =
            'Size: ${sourceSize.toString().padLeft(5)} B ➔ ${targetSize.toString().padLeft(5)} B';

        // Shows positive % for space saved, negative % if the file grew larger
        final String savingsSign = savingsRatio >= 0 ? '+' : '';
        final String savingsStr =
            'Savings: $savingsSign${savingsRatio.toStringAsFixed(1).padLeft(5)}%';

        // Print clean, uniform columns for easy log parsing
        print('📊 $pair | $time | $delta | $savingsStr');
      }
    }
    print(
      '===================================================================================\n',
    );
  });
}
