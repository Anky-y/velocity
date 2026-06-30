import 'package:flutter/services.dart';

class MediaStoreService {
  static const MethodChannel _channel = MethodChannel("velocity/media_store");

  static Future<Map<String, dynamic>> save({
    required String filePath,
    required String mediaType,
  }) async {
    final result = await _channel.invokeMethod('saveFile', {
      'path': filePath,
      'type': mediaType,
    });

    if (result == null) {
      throw Exception("Android returned null result.");
    }

    return Map<String, dynamic>.from(result);
  }

  static Future<bool> fileExists(String uri) async {
    final exists = await _channel.invokeMethod<bool>('fileExists', {
      'uri': uri,
    });

    return exists ?? false;
  }
}
