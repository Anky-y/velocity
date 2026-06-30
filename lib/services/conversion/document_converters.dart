import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';

class DocumentConverters {
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
    print("🚀 [CONVERTER] Starting Mammoth pipeline execution for: $inputPath");
    final completer = Completer<String>();

    try {
      // Step 1: Read raw original bytes (No zip manipulation needed for Mammoth!)
      print("📦 [CONVERTER] Step 1: Reading file bytes from disk...");
      final fileBytes = await File(inputPath).readAsBytes();
      final base64Document = base64Encode(fileBytes);

      // Step 2: Initialize Webview
      print("🌐 [CONVERTER] Step 2: Spawning WebViewController...");
      _activeController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'DocxBridge',
          onMessageReceived: (JavaScriptMessage message) {
            if (message.message.startsWith("ERROR:")) {
              print("❌ [CONVERTER] Mammoth Engine Error: ${message.message}");
              completer.completeError(Exception(message.message));
            } else {
              print(
                "📄 [CONVERTER] Mammoth successfully flattened document to HTML stream.",
              );
              completer.complete(message.message);
            }
          },
        );

      // Step 3: Load Asset
      print("📂 [CONVERTER] Step 3: Loading Mammoth HTML canvas asset...");
      await _activeController!.loadFlutterAsset('assets/converter/index.html');

      // Step 4: Warmup Delay
      print("⏳ [CONVERTER] Step 4: Holding for 800ms engine initialization...");
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 5: Run JS Matrix
      print("⚡ [CONVERTER] Step 5: Injecting document stream to Mammoth...");
      await _activeController!.runJavaScript(
        "convertDocxBytesToHtml('$base64Document');",
      );

      // Step 6: Wait for JS callback
      print(
        "⏳ [CONVERTER] Step 6: Waiting up to 15 seconds for layout response...",
      );
      final htmlOutput = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw TimeoutException("The Mammoth conversion engine timed out."),
      );

      // ─── STEP 7: GLOBAL TYPOGRAPHY & LAYOUT INJECTION ───
      print(
        "📝 [CONVERTER] Step 7: Structuring document rules and standard styling elements...",
      );
      String cleanOutput = htmlOutput;
      final structuredHtml =
          """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    * {
      -webkit-print-color-adjust: exact !important;
      print-color-adjust: exact !important;
      box-sizing: border-box !important;
    }

    @page { 
      margin: 15mm !important; /* Controlled edge margin for native PDF engine */
    }
    
    html, body { 
      background-color: #ffffff !important; 
      margin: 0px !important; 
      padding: 0px !important;
      height: auto !important;
    }

    .docx-wrapper {
      background: transparent !important;
      padding: 0px !important;
      margin: 0px !important;
      height: auto !important;
      display: block !important;
    }
    
    .docx {
      background-color: #ffffff !important;
      box-shadow: none !important;
      width: 100% !important;
      max-width: 100% !important;
      height: auto !important; 
      min-height: 0 !important;
      padding: 10px !important; 
      margin: 0px auto !important;
      display: block !important;
    }

    .docx section, .docx-page {
      background: transparent !important;
      box-shadow: none !important;
      width: 100% !important;
      height: auto !important; 
      min-height: 0 !important;
      padding: 0px !important;
      margin: 0px 0px 20px 0px !important;
      page-break-inside: auto !important; 
    }

    /* 🚨 SHAPE TEXT SAFETY NET 🚨 */
    /* Ensure text inside rescued cards is explicitly dark and visible */
    .docx-textbox-content, 
    .docx-textbox-content p, 
    .docx-textbox-content span {
      color: #111111 !important; /* Forces text to show against the card fill */
    }

    /* Image guardrails */
    img {
      max-width: 100% !important;
      height: auto !important;
      display: block !important;
    }

    /* Keep data tables fluid */
    .docx table {
      width: 100% !important;
      max-width: 100% !important;
      border-collapse: collapse !important;
      page-break-inside: auto !important;
    }
    
    tr {
      page-break-inside: avoid !important; 
      page-break-after: auto !important;
    }
  </style>
</head>
<body>
  $cleanOutput
</body>
</html>
""";

      // Step 8: PDF Compilation
      print(
        "🖨️ [CONVERTER] Step 8: Feeding flat HTML to native OS print frame...",
      );
      final converter = HtmlToPdfConverter();
      final pdfBytes = await converter.convertHtmlToPdfBytes(
        html: structuredHtml,
      );

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(pdfBytes);
      print(
        "🎉 [CONVERTER] Step 9: Saved file via clean Mammoth engine pipeline.",
      );

      return outputFile;
    } catch (e, stacktrace) {
      print("🚨 [CONVERTER CRASH] $e");
      print("🚨 Stacktrace: $stacktrace");
      rethrow;
    }
  }
}
