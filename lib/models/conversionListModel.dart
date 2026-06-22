import 'package:flutter/material.dart';

enum FileTypeCategory {
  image,
  video,
  document,
  audio,
}

class ConversionOption {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String routeName; // Where to go when tapped

  const ConversionOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.routeName,
  });
}

// 3. Model mapping a FileTypeCategory to its specific list of options
class CategoryConfig {
  final String pageTitle;
  final List<ConversionOption> options;

  const CategoryConfig({
    required this.pageTitle,
    required this.options,
  });
}