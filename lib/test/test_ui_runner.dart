import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:velocity/data/format_registry.dart';
import 'package:velocity/services/conversion/conversion_manager.dart';
import 'package:image/image.dart' as img;
import 'package:velocity/services/conversion/image_converters.dart';

class TestUiRunnerApp extends StatefulWidget {
  const TestUiRunnerApp({super.key});

  @override
  State<TestUiRunnerApp> createState() => _TestUiRunnerAppState();
}

class _TestUiRunnerAppState extends State<TestUiRunnerApp> {
  final List<String> _logs = [];
  bool _isRunning = false;
  String _outputPathMessage = '';

  void _runMatrixAnalytics() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
      _outputPathMessage = '';
      _logs.add('🚀 Initializing Public Hardware Matrix...');
    });

    // 🚀 THE GALLERY/FILES FIX: Save to the public App Documents directory instead of hidden temp
    final Directory? publicDir = await getExternalStorageDirectory();

    if (publicDir == null) return; // Quick safety check
    // Create a dedicated visible folder inside documents called "Velocity_Outputs"
    final testFolder = Directory(p.join(publicDir.path, 'Velocity_Outputs'));
    if (!testFolder.existsSync()) {
      testFolder.createSync(recursive: true);
    }

    setState(() {
      _outputPathMessage =
          '📁 Files saving to public storage:\n${testFolder.path}';
    });

    // Let's use a bigger 128x128 image so it looks like a real image in your file manager!
    final dummyImg = img.Image(width: 128, height: 128);
    // Draw a nice blue square with a yellow crosshair so you can check image quality visually
    img.fill(dummyImg, color: img.ColorRgb8(33, 150, 243));
    img.drawLine(
      dummyImg,
      x1: 0,
      y1: 0,
      x2: 128,
      y2: 128,
      color: img.ColorRgb8(255, 235, 59),
      thickness: 2,
    );
    img.drawLine(
      dummyImg,
      x1: 0,
      y1: 128,
      x2: 128,
      y2: 0,
      color: img.ColorRgb8(255, 235, 59),
      thickness: 2,
    );

    for (String sourceExt in FormatRegistry.conversionRules.keys) {
      // Create the test input file directly in our visible folder
      final sourcePath = p.join(
        testFolder.path,
        '00_SOURCE_ORIGINAL.$sourceExt',
      );
      final sourceFile = File(sourcePath);

      List<int> sourceBytes;
      switch (sourceExt.toLowerCase()) {
        case 'png':
          sourceBytes = Uint8List.fromList(img.PngEncoder().encode(dummyImg));
          break;
        case 'gif':
          sourceBytes = Uint8List.fromList(img.GifEncoder().encode(dummyImg));
          break;
        case 'bmp':
          sourceBytes = Uint8List.fromList(img.BmpEncoder().encode(dummyImg));
          break;
        case 'ico':
          sourceBytes = Uint8List.fromList(img.IcoEncoder().encode(dummyImg));
          break;
        case 'jpg':
        case 'jpeg':
          sourceBytes = Uint8List.fromList(img.JpegEncoder().encode(dummyImg));
          break;
        default:
          sourceBytes = Uint8List.fromList(img.PngEncoder().encode(dummyImg));
      }

      await sourceFile.writeAsBytes(sourceBytes);
      final int sourceSize = sourceFile.lengthSync();
      final targets = FormatRegistry.getAvailableTargets(sourceExt);

      for (String targetExt in targets) {
        if (targetExt.toLowerCase() == 'webp') continue;

        setState(() {
          _logs.add(
            '⏳ Converting: ${sourceExt.toUpperCase()} ➔ ${targetExt.toUpperCase()}...',
          );
        });

        // Execute pipeline
        final stopwatch = Stopwatch()..start();

        // Read from our explicit file
        final Uint8List fileBytes = await sourceFile.readAsBytes();
        final img.Image? decoded = img.decodeImage(fileBytes);

        if (decoded != null) {
          // Send it to your converter workers
          final Uint8List encodedBytes = Uint8List.fromList(
            ImageConverters.convertImageFormat(
              decoded,
              targetExt.toLowerCase(),
            ),
          );

          // Save output into the public directory with an unmistakable name structure
          final outPath = p.join(
            testFolder.path,
            'CONVERTED_FROM_${sourceExt.toUpperCase()}_TO.${targetExt.toLowerCase()}',
          );
          final outputFile = File(outPath);
          await outputFile.writeAsBytes(encodedBytes);

          stopwatch.stop();

          final int targetSize = outputFile.lengthSync();
          final double savingsRatio = (1.0 - (targetSize / sourceSize)) * 100;
          final double durationMs = stopwatch.elapsedMicroseconds / 1000.0;
          final String sign = savingsRatio >= 0 ? '+' : '';

          setState(() {
            _logs.removeLast();
            _logs.add(
              '💾 [EXPORTED] ${sourceExt.toUpperCase()} ➔ ${targetExt.toUpperCase()}\n'
              '   ⏱️ ${durationMs.toStringAsFixed(1)}ms | 💾 ${targetSize} Bytes | 📉 Savings: $sign${savingsRatio.toStringAsFixed(1)}%',
            );
          });
        }

        await Future.delayed(
          const Duration(milliseconds: 200),
        ); // Delay to watch UI animate
      }
    }

    setState(() {
      _isRunning = false;
      _logs.add('🎉 Complete! Go check your device file explorer!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Velocity Matrix UI Pipeline'),
          backgroundColor: Colors.indigo,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.folder_shared),
                label: Text(
                  _isRunning
                      ? 'Writing Files to Storage...'
                      : 'Generate Matrix in Public Files',
                ),
                onPressed: _isRunning ? null : _runMatrixAnalytics,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ),
            if (_outputPathMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _outputPathMessage,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final isData = log.startsWith('💾');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isData
                              ? Colors.tealAccent
                              : Colors.amberAccent,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
