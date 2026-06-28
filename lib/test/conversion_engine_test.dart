import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'dart:typed_data';

import 'package:velocity/data/format_registry.dart';
import 'package:velocity/services/conversion/conversion_manager.dart';

void main() {
  // Ensure the underlying Flutter engine plugins (path_provider, ffmpeg) are alive
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  group('Velocity Universal Hardware Matrix Benchmarks', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await getTemporaryDirectory();
    });

    for (String sourceExt in FormatRegistry.conversionRules.keys) {
      test('Matrix Validation Pipeline: [ $sourceExt ]', () async {
        final category =
            FormatRegistry.extensionToCategory[sourceExt.toLowerCase()] ??
            'Image';
        final sourcePath = p.join(tempDir.path, 'bench_source.$sourceExt');
        final sourceFile = File(sourcePath);

        // --- AUTOMATED ASSET CREATION PIPELINE ---
        if (category == 'Image') {
          final dummyImg = img.Image(width: 32, height: 32)
            ..clear(img.ColorRgb8(0, 0, 255));
          Uint8List bytes;
          if (sourceExt.toLowerCase() == 'png') {
            bytes = Uint8List.fromList(img.PngEncoder().encode(dummyImg));
          } else if (sourceExt.toLowerCase() == 'gif') {
            bytes = Uint8List.fromList(img.GifEncoder().encode(dummyImg));
          } else if (sourceExt.toLowerCase() == 'bmp') {
            bytes = Uint8List.fromList(img.BmpEncoder().encode(dummyImg));
          } else if (sourceExt.toLowerCase() == 'ico') {
            bytes = Uint8List.fromList(img.IcoEncoder().encode(dummyImg));
          } else {
            bytes = Uint8List.fromList(img.JpegEncoder().encode(dummyImg));
          }

          await sourceFile.writeAsBytes(bytes);
        } else if (category == 'Video' ||
            sourceExt.toLowerCase() == 'mp3' ||
            sourceExt.toLowerCase() == 'wav') {
          // 🚀 FFmpeg Superpower: Create a lightning-fast synthetic 1-second video/audio framework block
          // This generates a simple color pattern so we have actual real stream frames to convert!
          final String genCommand =
              '-f lavfi -i testsrc=duration=1:size=160x120:rate=10 -f lavfi -i sine=duration=1:frequency=440 "$sourcePath" -y';
          final session = await FFmpegKit.execute(genCommand);
          final returnCode = await session.getReturnCode();
          if (!ReturnCode.isSuccess(returnCode)) {
            fail(
              'Failed to synthesize baseline benchmark asset for format: $sourceExt',
            );
          }
        }

        final int sourceSize = sourceFile.lengthSync();
        final targets = FormatRegistry.getAvailableTargets(sourceExt);

        for (String targetExt in targets) {
          // Skip WebP if it relies on separate native plugins your test environment lacks
          if (targetExt.toLowerCase() == 'webp') continue;

          final stopwatch = Stopwatch()..start();

          // Execute dynamically mapped architecture types
          final convertedFile = await ConversionManager.execute(
            filePath: sourceFile.path,
            fromExtension: sourceExt,
            targetExtension: targetExt,
            fileType: category
                .toLowerCase(), // Maps 'image' or 'video' directly!
            onProgress: (_) {},
          );

          stopwatch.stop();

          final int targetSize = convertedFile.lengthSync();
          final double durationMs = stopwatch.elapsedMicroseconds / 1000.0;
          final double savingsRatio = (1.0 - (targetSize / sourceSize)) * 100;
          final String sign = savingsRatio >= 0 ? '+' : '';

          expect(
            convertedFile.existsSync(),
            true,
            reason: 'Failed outputting $sourceExt ➔ $targetExt',
          );
          expect(targetSize, greaterThan(0));

          // Log parsing layouts
          final String pair =
              '[${sourceExt.toUpperCase().padRight(4)} ➔ ${targetExt.toUpperCase().padRight(4)}]';
          final String time =
              'Time: ${durationMs.toStringAsFixed(2).padLeft(7)}ms';
          final String delta =
              'Size: ${sourceSize.toString().padLeft(6)} B ➔ ${targetSize.toString().padLeft(6)} B';
          final String ratio =
              'Savings: $sign${savingsRatio.toStringAsFixed(1).padLeft(5)}%';

          print('📊 $pair | $time | $delta | $ratio | 🏷️ Type: $category');
        }
      });
    }

    tearDownAll(() {
      print(
        '\n===================================================================================\n',
      );
    });
  });
}
