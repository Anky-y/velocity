class FormatRegistry {
  static const Map<String, List<String>> conversionRules = {
    // Images
    'png': ['jpg', 'jpeg', 'gif', 'bmp', 'ico', 'webp', 'tiff'],
    'jpg': ['png', 'gif', 'bmp', 'ico', 'webp', 'tiff'],
    'jpeg': ['png', 'gif', 'bmp', 'ico', 'webp', 'tiff'],
    'webp': ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'tiff'],
    'bmp': ['png', 'jpg', 'jpeg', 'gif', 'webp'],
    'ico': ['png', 'jpg', 'jpeg'],
    'tiff': ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
    'heic': ['png', 'jpg', 'jpeg', 'webp'],

    // Animations
    'gif': ['png', 'jpg', 'jpeg', 'bmp', 'webp', 'mp4', 'mov', 'webm'],

    // Video
    'mp4': [
      'gif',
      'mov',
      'webm',
      'avi',
      'mkv',
      'mp3',
      'wav',
      'm4a',
      'flac',
      'ogg',
    ],
    'mov': [
      'mp4',
      'gif',
      'webm',
      'avi',
      'mkv',
      'mp3',
      'wav',
      'm4a',
      'flac',
      'ogg',
    ],
    'webm': ['mp4', 'mov', 'gif', 'avi', 'mkv', 'mp3', 'wav', 'ogg'],
    'avi': ['mp4', 'mov', 'gif', 'mkv', 'webm', 'mp3', 'wav'],
    'mkv': ['mp4', 'mov', 'gif', 'avi', 'webm', 'mp3', 'wav'],

    // Audio
    'mp3': ['wav', 'm4a', 'flac', 'ogg'],
    'wav': ['mp3', 'm4a', 'flac', 'ogg'],
    'm4a': ['mp3', 'wav', 'flac', 'ogg'],
    'flac': ['mp3', 'wav', 'm4a', 'ogg'],
    'ogg': ['mp3', 'wav', 'm4a', 'flac'],

    // Document
    'pdf': ['txt'],
    'docx': ['pdf'],
  };

  // Updated to distinctly separate Video and Audio formats
  static const Map<String, String> extensionToCategory = {
    // 🖼️ Images
    'png': 'Image',
    'jpg': 'Image',
    'jpeg': 'Image',
    'webp': 'Image',
    'gif': 'Image', // Kept as image category for standard asset registration
    'bmp': 'Image',
    'ico': 'Image',
    'tiff': 'Image',
    'heic': 'Image',

    // 🎬 Video Formats
    'mp4': 'Video',
    'mov': 'Video',
    'webm': 'Video',
    'avi': 'Video',
    'mkv': 'Video',

    // 🎵 Audio Formats
    'mp3': 'Audio',
    'wav': 'Audio',
    'm4a': 'Audio',
    'flac': 'Audio',
    'ogg': 'Audio',

    // Document Formats
    'pdf': 'Document',
    'docx': 'Document',
    'txt': 'Document',
  };

  static bool isSupported(String extension) {
    return FormatRegistry.conversionRules.containsKey(extension);
  }

  static List<String> getAvailableTargets(String extension) {
    return conversionRules[extension.toLowerCase()] ?? [];
  }

  /// Groups target formats into distinct Categories (Image, Document, Video, Audio)
  static Map<String, List<String>> getCategorizedTargets(List<String> targets) {
    final Map<String, List<String>> categorized = {};

    for (var target in targets) {
      final category = extensionToCategory[target.toLowerCase()] ?? 'Other';

      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(target.toUpperCase());
    }
    return categorized;
  }

  /// UNIVERSAL HELPER (UNION): Pass a list of input extensions, returns ALL possible unique outputs
  static List<String> getCommonTargets(List<String> extensions) {
    if (extensions.isEmpty) return [];

    final Set<String> combinedTargets = {};

    for (var ext in extensions) {
      // Fetch individual targets and add them all to the Set (auto-handles duplicates)
      final targets = getAvailableTargets(ext);
      combinedTargets.addAll(targets);
    }

    return combinedTargets.toList()..sort();
  }
}
