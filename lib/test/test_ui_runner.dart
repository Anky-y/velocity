import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:velocity/data/format_registry.dart';
import 'package:velocity/services/conversion/conversion_manager.dart';
import 'package:image/image.dart' as img;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

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
      _logs.add('🚀 Initializing Public Media Hardware Matrix...');
    });

    // 1. Determine public folder destination path
    Directory? publicDir;
    if (Platform.isAndroid) {
      publicDir = Directory('/storage/emulated/0/Documents');
    } else {
      publicDir = await getApplicationDocumentsDirectory();
    }

    if (publicDir == null || !publicDir.existsSync()) {
      publicDir = await getExternalStorageDirectory();
    }

    final testFolder = Directory(p.join(publicDir!.path, 'Velocity_Outputs'));
    if (!testFolder.existsSync()) {
      testFolder.createSync(recursive: true);
    }

    setState(() {
      _outputPathMessage = '📁 Output Directory:\n${testFolder.path}';
    });

    // 2. Generate standard base memory layout for raw image generation
    final dummyImg = img.Image(width: 128, height: 128);
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
      final cleanSrc = sourceExt.toLowerCase().trim();
      final category = FormatRegistry.extensionToCategory[cleanSrc] ?? 'Image';

      final sourcePath = p.join(
        testFolder.path,
        '00_SOURCE_ORIGINAL.$cleanSrc',
      );
      final sourceFile = File(sourcePath);

      setState(() {
        _logs.add(
          '📦 Creating baseline asset for format: ${sourceExt.toUpperCase()}...',
        );
      });

      // --- GENERATE RAW SOURCE ASSETS ---
      if (category == 'Image') {
        Uint8List sourceBytes;
        switch (cleanSrc) {
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
            sourceBytes = Uint8List.fromList(img.encodeIco(dummyImg));
            break;
          default:
            sourceBytes = Uint8List.fromList(
              img.JpegEncoder().encode(dummyImg),
            );
        }
        await sourceFile.writeAsBytes(sourceBytes);
      } else if (category == 'Audio') {
        final genCommand =
            '-f lavfi -i sine=duration=1:frequency=440 "$sourcePath" -y';
        final session = await FFmpegKit.execute(genCommand);
        final returnCode = await session.getReturnCode();
        if (!ReturnCode.isSuccess(returnCode)) {
          setState(
            () =>
                _logs.add('⚠️ Failed synthesizing frame asset for: $sourceExt'),
          );
          continue;
        }
      } else if (category == 'Video') {
        String videoCodec = 'libx264';
        String audioCodec = 'aac';

        if (cleanSrc == 'webm') {
          videoCodec = 'libvpx';
          audioCodec = 'libvorbis';
        }

        final genCommand =
            '-f lavfi -i testsrc=duration=1:size=160x120:rate=10 -f lavfi -i sine=duration=1:frequency=440 -c:v $videoCodec -pix_fmt yuv420p -c:a $audioCodec -shortest "$sourcePath" -y';
        final session = await FFmpegKit.execute(genCommand);
        final returnCode = await session.getReturnCode();
        if (!ReturnCode.isSuccess(returnCode)) {
          setState(
            () =>
                _logs.add('⚠️ Failed synthesizing frame asset for: $sourceExt'),
          );
          continue;
        }
      }

      // 🗺️ BACK OUTSIDE THE CONDITIONAL BLOCKS: Process conversion matrix for all keys
      final int sourceSize = sourceFile.lengthSync();
      final targets = FormatRegistry.getAvailableTargets(cleanSrc);

      // Clean status placeholder line
      setState(() => _logs.removeLast());

      for (String targetExt in targets) {
        if (targetExt.toLowerCase() == 'webp') continue;

        setState(() {
          _logs.add(
            '⏳ Processing: ${sourceExt.toUpperCase()} ➔ ${targetExt.toUpperCase()}...',
          );
        });

        final stopwatch = Stopwatch()..start();

        try {
          // 3. Execute Core Production Architecture Pipeline Code
          final File tempConvertedFile = await ConversionManager.execute(
            filePath: sourceFile.path,
            fromExtension: cleanSrc,
            targetExtension: targetExt,
            fileType: category.toLowerCase(),
            onProgress: (_) {},
          );

          // 4. Copy output to public directory for tracking
          final publicOutPath = p.join(
            testFolder.path,
            'CONVERTED_FROM_${sourceExt.toUpperCase()}_TO_${targetExt.toUpperCase()}.${targetExt.toLowerCase()}',
          );
          final publicFile = await tempConvertedFile.copy(publicOutPath);

          stopwatch.stop();

          final int targetSize = publicFile.lengthSync();
          final double savingsRatio = (1.0 - (targetSize / sourceSize)) * 100;
          final double durationMs = stopwatch.elapsedMicroseconds / 1000.0;
          final String sign = savingsRatio >= 0 ? '+' : '';

          setState(() {
            _logs.removeLast();
            _logs.add(
              '🎬 [EXPORTED] ${sourceExt.toUpperCase()} ➔ ${targetExt.toUpperCase()}\n'
              '   ⏱️ ${durationMs.toStringAsFixed(1)}ms | 💾 ${targetSize}B | 📉 Savings: $sign${savingsRatio.toStringAsFixed(1)}% | 🏷️ $category',
            );
          });
        } catch (e) {
          stopwatch.stop();
          setState(() {
            _logs.removeLast();
            _logs.add(
              '❌ [FAILED] ${sourceExt.toUpperCase()} ➔ ${targetExt.toUpperCase()}\n   Error: $e',
            );
          });
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    setState(() {
      _isRunning = false;
      _logs.add('🎉 Complete! Go check your device file manager output!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Velocity Media Matrix UI'),
          backgroundColor: Colors.deepPurple,
          actions: [
            // 📋 FOOTPRINT COPY ACTION BUTTON
            IconButton(
              icon: const Icon(Icons.copy_all),
              tooltip: 'Copy all logs to clipboard',
              onPressed: _logs.isEmpty
                  ? null
                  : () async {
                      final allLogsText = _logs.join('\n');
                      await Clipboard.setData(ClipboardData(text: allLogsText));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '📋 All matrix logs copied to clipboard!',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Run Benchmarks'),
                      onPressed: _isRunning ? null : _runMatrixAnalytics,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: _isRunning ? null : _clearConvertedFiles,
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                  ),
                ],
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
                    Color textColor = Colors.amberAccent;
                    if (log.startsWith('🎬')) textColor = Colors.tealAccent;
                    if (log.startsWith('❌')) textColor = Colors.redAccent;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: textColor,
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

  void _clearConvertedFiles() async {
    // 1. Resolve exact matching path used by runner
    Directory? publicDir;
    if (Platform.isAndroid) {
      publicDir = Directory('/storage/emulated/0/Documents');
    } else {
      publicDir = await getApplicationDocumentsDirectory();
    }

    if (publicDir == null || !publicDir.existsSync()) {
      publicDir = await getExternalStorageDirectory();
    }

    final testFolder = Directory(p.join(publicDir!.path, 'Velocity_Outputs'));

    // 2. Perform deep clean if directory exists
    if (testFolder.existsSync()) {
      try {
        final files = testFolder.listSync();
        int deletedCount = 0;

        for (var file in files) {
          if (file is File) {
            final name = p.basename(file.path);
            // Catch baseline originals as well as conversion outputs
            if (name.contains('CONVERTED_FROM_') ||
                name.contains('00_SOURCE_ORIGINAL.')) {
              file.deleteSync();
              deletedCount++;
            }
          }
        }

        setState(() {
          _logs.clear();
          _logs.add(
            '🗑️ Cleaned $deletedCount test assets from /Velocity_Outputs/ successfully!',
          );
        });
      } catch (e) {
        setState(() {
          _logs.add('❌ Cleanup partition failure: $e');
        });
      }
    } else {
      setState(() {
        _logs.clear();
        _logs.add('📂 No output folder found to purge.');
      });
    }
  }
}
