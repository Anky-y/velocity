import 'package:image/image.dart' as img;

class ImageConverters {
  /// Pure worker function dedicated strictly to handling image-to-image encoding blocks
  static List<int> convertImageFormat(
    img.Image decodedImage,
    String targetExtension,
  ) {
    final cleanTarget = targetExtension.toLowerCase().trim();
    switch (cleanTarget) {
      case 'jpg':
      case 'jpeg':
        return img.encodeJpg(decodedImage, quality: 85);
      case 'png':
        return img.encodePng(decodedImage);
      case 'gif':
        return img.encodeGif(decodedImage);
      case 'bmp':
        return img.encodeBmp(decodedImage);
      case 'ico':
        return img.encodeIco(decodedImage);
      default:
        // 🚀 Change this line so it reports the exact culprit:
        throw Exception(
          "Format '$cleanTarget' not supported inside ImageConverters worker pipeline.",
        );
    }
  }
}
