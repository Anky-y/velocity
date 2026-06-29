import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';

class VideoAudioConverters {
  /// Pure worker function dedicated strictly to handling FFmpeg video/audio encoding tasks
  static Future<File> convertVideoAudioFormat({
    required String inputPath,
    required String outputPath,
    required String targetExtension, // 🚀 ADD THIS PARAMETER
    void Function(double progress)? onProgress,
  }) async {
    final completer = Completer<File>();
    final cleanTarget = targetExtension
        .toLowerCase()
        .replaceAll('.', '')
        .trim();
    // Build the core FFmpeg instruction payload
    String command;
    if (cleanTarget == 'gif') {
      command = '-i "$inputPath" -vf "fps=10,scale=160:-1" -an "$outputPath"';
    } else if (cleanTarget == 'webm') {
      // Universal WebM target delivery
      command =
          '-i "$inputPath" -c:v libvpx -pix_fmt yuv420p -c:a libvorbis "$outputPath"';
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(cleanTarget)) {
      // Standard universal container codecs
      command =
          '-i "$inputPath" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 128k "$outputPath"';
    } else if ([
      'png',
      'jpg',
      'jpeg',
      'bmp',
      'ico',
      'tiff',
    ].contains(cleanTarget)) {
      // 🖼️ EXTRACT FIRST FRAME FROM ANIMATION TO STATIC IMAGE
      command = '-i "$inputPath" -vframes 1 "$outputPath" -y';
    } else {
      // Pure audio outputs (mp3, wav, m4a, flac, ogg)
      command = '-i "$inputPath" -vn "$outputPath"';
    }

    onProgress?.call(0.2); // FFmpeg task initialization point

    await FFmpegKit.executeAsync(
      command,
      (Session session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          onProgress?.call(1.0); // Signal task completion
          completer.complete(File(outputPath));
        } else {
          final logList = await session.getLogs();
          final String systemErrors = logList
              .map((l) => l.getMessage())
              .where(
                (msg) =>
                    msg.contains('Error') ||
                    msg.contains('Invalid') ||
                    msg.contains('Cannot'),
              )
              .take(
                3,
              ) // Grab the top 3 lines so it doesn't overflow your UI display panel
              .join(' | ');

          final cleanErrorMessage = systemErrors.isNotEmpty
              ? systemErrors
              : "FFmpeg internal pipe failure.";

          completer.completeError(
            Exception(
              "Video Conversion Failed (Code: $returnCode).\nLogs: $cleanErrorMessage",
            ),
          );
        }
      },
      (log) {
        // Optional: Route raw console logs here if required for deep debugging
        print('🎥 [FFmpeg Log]: ${log.getMessage()}');
      },
      (statistics) {
        // Optional: Parse frame count vs total duration to map a rolling layout percentage
        onProgress?.call(0.5);
      },
    );

    return completer.future;
  }
}
