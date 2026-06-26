class FormatRegistry {
  static const Map<String, List<String>> conversionRules = {
    'png': ['jpg', 'jpeg', 'webp', 'pdf', 'gif'],
    'jpg': ['png', 'webp', 'pdf', 'gif'],
    'jpeg': ['png', 'webp', 'pdf', 'gif'],
    
    'pdf': ['docx', 'jpg', 'png'],
    'docx': ['pdf', 'txt'],
    
    'mp4': ['gif', 'mp3', 'mov', 'wav'],
    'mp3': ['wav', 'm4a'],
    'wav': ['mp3', 'm4a'],
  };

  // Updated to distinctly separate Video and Audio formats
  static const Map<String, String> extensionToCategory = {
    // Images
    'png': 'Image', 'jpg': 'Image', 'jpeg': 'Image', 'webp': 'Image', 'gif': 'Image',
    
    // Documents
    'pdf': 'Document', 'docx': 'Document', 'txt': 'Document',
    
    // Video Formats
    'mp4': 'Video', 'mov': 'Video',
    
    // Audio Formats
    'mp3': 'Audio', 'wav': 'Audio', 'm4a': 'Audio',
  };

  static bool isSupported(String extension) {
    return FormatRegistry.conversionRules.containsKey(extension);
  }

  static List<String> getTargets(String extension) {
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
    final targets = getTargets(ext);
    combinedTargets.addAll(targets);
  }
  
  return combinedTargets.toList()..sort();
}
}