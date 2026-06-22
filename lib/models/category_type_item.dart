import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity/models/conversionListModel.dart';


class CategoryTypeItem {
  final FaIconData icon;
  final String name;
  final Color color;
  final FileTypeCategory category; 

  CategoryTypeItem({
    required this.icon,
    required this.name,
    required this.color,
    required this.category, 
  });
}