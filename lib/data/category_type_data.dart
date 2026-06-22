import 'package:velocity/core/theme/app_colors.dart';
import '../models/category_type_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/conversionListModel.dart';

class CategoryTypeData {
  static final List<CategoryTypeItem> items = [
    CategoryTypeItem(
      icon: FontAwesomeIcons.file,
      name: "Documents",
      color: LightColors.accent,
      category: FileTypeCategory.document,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.image,
      name: "Images",
      color: LightColors.secondary,
      category: FileTypeCategory.image,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.headphones,
      name: "Audio",
      color: LightColors.primary,
      category: FileTypeCategory.audio,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.video,
      name: "Video",
      color: LightColors.accent,
      category: FileTypeCategory.video,
    ),
    CategoryTypeItem(
      icon: FontAwesomeIcons.server,
      name: "Utilities",
      color: LightColors.mutedText,
      category: FileTypeCategory.utilities,
    ),
  ];
}
