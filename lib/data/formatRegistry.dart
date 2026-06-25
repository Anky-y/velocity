class FormatRegistry {
  // A map of: sourceExtension -> List of allowed targetExtensions
  static const Map<String, List<String>> conversionRules = {
    // Images
    'png': ['jpg', 'jpeg', 'webp', 'pdf', 'gif'],
    'jpg': ['png', 'webp', 'pdf', 'gif'],
    'jpeg': ['png', 'webp', 'pdf', 'gif'],
    
    // Documents
    'pdf': ['docx', 'jpg', 'png'],
    'docx': ['pdf', 'txt'],
    
    // Video/Audio
    'mp4': ['gif', 'mp3', 'mov', 'wav'],
    'mp3': ['wav', 'm4a'],
    'wav': ['mp3', 'm4a'],
  };

  // Optional: For the "Universal Output" dropdown, we might want a list of ALL possible outputs
  static List<String> get allPossibleTargets {
    final Set<String> targets = {};
    for (var list in conversionRules.values) {
      targets.addAll(list);
    }
    return targets.toList()..sort();
  }
}