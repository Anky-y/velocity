import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity/models/recent_file_item.dart';

class RecentFilesData {
  static final List<RecentFileItem> items = [
    RecentFileItem(
      icon: FontAwesomeIcons.filePdf,
      name: "Report_Final.pdf",
      color: Colors.red,
      convertedFrom: "DOCX → PDF",
      time: DateTime.now().subtract(const Duration(minutes: 10)),
    ),

    RecentFileItem(
      icon: FontAwesomeIcons.image,
      name: "IMG_2026.png",
      color: Colors.blue,
      convertedFrom: "PNG → JPG",
      time: DateTime.now().subtract(const Duration(minutes: 35)),
    ),

    RecentFileItem(
      icon: FontAwesomeIcons.fileImage,
      name: "banner_design.jpg",
      color: Colors.orange,
      convertedFrom: "JPG → PNG",
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    ),

    RecentFileItem(
      icon: FontAwesomeIcons.fileVideo,
      name: "intro_video.mp4",
      color: Colors.purple,
      convertedFrom: "MP4 → GIF",
      time: DateTime.now().subtract(const Duration(hours: 3)),
    ),

    RecentFileItem(
      icon: FontAwesomeIcons.fileAudio,
      name: "podcast_edit.mp3",
      color: Colors.green,
      convertedFrom: "MP3 → WAV",
      time: DateTime.now().subtract(const Duration(hours: 6, minutes: 15)),
    ),

    RecentFileItem(
      icon: FontAwesomeIcons.fileZipper,
      name: "assets_bundle.zip",
      color: Colors.teal,
      convertedFrom: "PDF → ZIP",
      time: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
  ];
}
