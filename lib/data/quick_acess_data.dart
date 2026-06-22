import 'package:velocity/core/theme/app_colors.dart';
import '../models/quick_access_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuickAccessData {
  static final List<QuickAccessItem> items = [
    QuickAccessItem(
      icon: FontAwesomeIcons.fileImage,
      name: "PNG → JPG",
      color: LightColors.primary,
    ),
    QuickAccessItem(
      icon: FontAwesomeIcons.filePdf,
      name: "JPG → PDF",
      color: LightColors.secondary,
    ),
    QuickAccessItem(
      icon: FontAwesomeIcons.fileVideo,
      name: "MP4 → GIF",
      color: LightColors.accent,
    ),
    QuickAccessItem(
      icon: FontAwesomeIcons.fileAudio,
      name: "MP3 → WAV",
      color: LightColors.primary,
    ),
    QuickAccessItem(
      icon: FontAwesomeIcons.file,
      name: "DOC → PDF",
      color: LightColors.secondary,
    ),
  ];
}
