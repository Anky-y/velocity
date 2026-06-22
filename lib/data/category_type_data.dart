import 'package:velocity/core/theme/app_colors.dart';
import '../models/category_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryTypeData {
  static final List<CategoryTypeItem> items = [
    CategoryTypeItem(
      icon: FontAwesomeIcons.file,
      name: "Documents",
      color: LightColors.accent,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.image,
      name: "Images",
      color: LightColors.secondary,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.headphones,
      name: "Audio",
      color: LightColors.primary,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.video,
      name: "Video",
      color: LightColors.accent,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.server,
      name: "Utilities",
      color: LightColors.mutedText,
    ),
  ];
}
