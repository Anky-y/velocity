import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecentFileItem {
  final FaIconData icon;
  final String name;
  final Color color;
  final String convertedFrom;
  final DateTime time;

  RecentFileItem({
    required this.icon,
    required this.name,
    required this.color,
    required this.convertedFrom,
    required this.time,
  });
}
