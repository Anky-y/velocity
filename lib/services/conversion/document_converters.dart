import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';

class DocumentConverters {
  // Keep a reference to the controller so it doesn't get garbage collected
  static WebViewController? _activeController;

  static Future<File> convertDocumentFormat({
    required String filePath,
    required String outputPath,
    required String targetExtension,
  }) async {
    final cleanTarget = targetExtension.toLowerCase().trim();

    if (filePath.toLowerCase().endsWith('.pdf') && cleanTarget == 'txt') {
      return File(outputPath);
    } else if (filePath.toLowerCase().endsWith('.docx') &&
        cleanTarget == 'pdf') {
      return await _executeDocxToPdf(filePath, outputPath);
    } else {
      throw Exception(
        "Unsupported document pipeline pair: ${p.extension(filePath)} ➔ $cleanTarget",
      );
    }
  }

  static Future<File> _executeDocxToPdf(
    String inputPath,
    String outputPath,
  ) async {
    print("🚀 [CONVERTER] Starting pipeline execution for: $inputPath");
    final completer = Completer<String>();

    try {
      // Step 1: Read Bytes
      print("📦 [CONVERTER] Step 1: Reading file bytes from disk...");
      final fileBytes = await File(inputPath).readAsBytes();
      final base64Document = base64Encode(fileBytes);
      print("📦 [CONVERTER] Success: Read ${fileBytes.length} bytes.");

      // Step 2: Initialize Webview
      print(
        "🌐 [CONVERTER] Step 2: Spawning WebViewController configuration...",
      );
      _activeController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'DocxBridge',
          onMessageReceived: (JavaScriptMessage message) {
            print("📩 [CONVERTER] JavaScript Bridge callback triggered!");
            if (message.message.startsWith("ERROR:")) {
              print(
                "❌ [CONVERTER] JS Engine reported internal error: ${message.message}",
              );
              completer.completeError(Exception(message.message));
            } else {
              print(
                "📄 [CONVERTER] JS Engine successfully extracted HTML string layout.",
              );
              completer.complete(message.message);
            }
          },
        );

      // Step 3: Load Asset
      print("📂 [CONVERTER] Step 3: Attempting to load index.html asset...");
      await _activeController!.loadFlutterAsset('assets/converter/index.html');
      print("📂 [CONVERTER] Asset load command dispatched.");

      // Step 4: Warmup Delay
      print("⏳ [CONVERTER] Step 4: Holding for 800ms engine initialization...");
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 5: Run JS Matrix
      print(
        "⚡ [CONVERTER] Step 5: Injecting and executing convertDocxBytesToHtml()...",
      );
      await _activeController!.runJavaScript(
        "convertDocxBytesToHtml('$base64Document');",
      );
      print("⚡ [CONVERTER] JavaScript string execution completed.");

      // Step 6: Wait for JS callback with a definitive timeout
      print(
        "⏳ [CONVERTER] Step 6: Waiting up to 15 seconds for JS Completer token...",
      );
      final htmlOutput = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          "The JavaScript conversion engine timed out.",
        ),
      );

      // Step 7: Build document wrapper
      print(
        "📝 [CONVERTER] Step 7: Compiling raw HTML to structured document string...",
      );
      final structuredHtml =
          """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: sans-serif; margin: 20px; line-height: 1.5; }
          img { max-width: 100%; height: auto; }
          table { border-collapse: collapse; width: 100%; margin: 12px 0; }
          th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        </style>
      </head>
      <body>
        $htmlOutput
      </body>
      </html>
      """;

      // Step 8: PDF Compilation
      print(
        "🖨️ [CONVERTER] Step 8: Passing HTML block to native OS print frame...",
      );
      final converter = HtmlToPdfConverter();
      final pdfBytes = await converter.convertHtmlToPdfBytes(
        html: structuredHtml,
      );
      print(
        "🖨️ [CONVERTER] Success: Generated ${pdfBytes.length} native PDF bytes.",
      );

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(pdfBytes);
      print("🎉 [CONVERTER] Step 9: Saved file to output path. Task complete.");

      return outputFile;
    } catch (e, stacktrace) {
      print("🚨 [CONVERTER CRASH] Pipeline stopped working!");
      print("🚨 Error Detail: $e");
      print("🚨 Stacktrace: $stacktrace");
      rethrow; // Forces the UI layer try/catch block to register the error and hide the loading spinner
    }
  }
}
