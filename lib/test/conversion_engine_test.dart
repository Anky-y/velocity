import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:velocity/data/format_registry.dart';
import 'package:velocity/services/conversion/conversion_manager.dart';

/// Intercepts native path_provider channel loops during headless VM testing suites
class MockPathProviderPlatform extends PathProviderPlatform {
  final String tempPath;
  MockPathProviderPlatform(this.tempPath);

  @override
  Future<String?> getTemporaryPath() async => tempPath;
}

void main() {
  // Configures the structural Flutter engine framework bindings
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('velocity_tests');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test(
    'Verify all image conversions run successfully with Deep Performance Matrix',
    () async {
      // 1. Create a 32x32 dummy canvas giving codecs realistic pixel blocks to process
      final dummyImg = img.Image(width: 32, height: 32)
        ..clear(img.ColorRgb8(0, 255, 0)); // Green validation block

      print(
        '\n===================================================================================',
      );
      print(
        '                      UNRESTRICTED PIPELINE METRICS MATRIX                         ',
      );
      print(
        '===================================================================================',
      );

      // 2. Unrestricted Loop: Scan every source type registered in your core framework configuration
      for (String sourceExt in FormatRegistry.conversionRules.keys) {
        final sourcePath = p.join(tempDir.path, 'test_source.$sourceExt');
        final sourceFile = File(sourcePath);

        // Encode matching binary headers explicitly to force exact platform decoding execution paths
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
            sourceBytes = img.IcoEncoder().encode(dummyImg);
            break;
          case 'jpg':
          case 'jpeg':
            sourceBytes = img.JpegEncoder().encode(dummyImg);
            break;
          case 'webp':
            // Pure Dart setup has a read-only WebP decoder, so fallback to valid stream arrays
            sourceBytes = img.PngEncoder().encode(dummyImg);
            break;
          default:
            sourceBytes = img.JpegEncoder().encode(dummyImg);
        }

        await sourceFile.writeAsBytes(sourceBytes);
        final int sourceSize = sourceFile.lengthSync();

        // 3. Collect and verify target combinations mapping rules
        final targets = FormatRegistry.getAvailableTargets(sourceExt);
        expect(
          targets.isNotEmpty,
          true,
          reason:
              'Execution stopped: No targets configured under Registry keys for: $sourceExt',
        );

        for (String targetExt in targets) {
          if (targetExt.toLowerCase() == 'webp')
            continue; // Omit read-only limits

          // ⏱️ Precision timing instantiation
          final stopwatch = Stopwatch()..start();

          final convertedFile = await ConversionManager.execute(
            filePath: sourceFile.path,
            fromExtension: sourceExt,
            targetExtension: targetExt,
            onProgress:
                (_) {},
                 // Quieting logging layers to keep analytics clear
          );

          stopwatch.stop();

          // 📊 Metrics computations
          final int targetSize = convertedFile.lengthSync();
          final double savingsRatio =
              (1.0 - (targetSize / sourceSize)) * 100; // Calculates space saved
          final double durationMs = stopwatch.elapsedMicroseconds / 1000.0;

          // Strict file status assertions
          expect(
            convertedFile.existsSync(),
            true,
            reason: 'Failed converting $sourceExt → $targetExt',
          );
          expect(
            targetSize,
            greaterThan(0),
            reason:
                'Output payload resulted in 0 bytes ($sourceExt → $targetExt)',
          );

          // Format and align text outputs cleanly into columns
          final String pair =
              '[${sourceExt.toUpperCase().padRight(4)} ➔ ${targetExt.toUpperCase().padRight(4)}]';
          final String time =
              'Time: ${durationMs.toStringAsFixed(2).padLeft(7)}ms';
          final String delta =
              'Size: ${sourceSize.toString().padLeft(5)} B ➔ ${targetSize.toString().padLeft(5)} B';

          // Shows positive % for space saved, negative % if the file grew larger
          final String savingsSign = savingsRatio >= 0 ? '+' : '';
          final String ratio =
              'Savings: $savingsSign${savingsRatio.toStringAsFixed(1).padLeft(5)}%';

          print('📊 $pair | $time | $delta | $ratio');
        }
        print(
          String.fromCharCodes(Iterable.generate(83, (_) => 45)),
        ); // Dotted section separator
      }
    },
  );
}
